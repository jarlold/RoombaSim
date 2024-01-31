import java.util.Arrays;
class NicheBreeder extends Thread {
  
  // Basic Settings
  final int INPUT_VECTOR_SIZE = 8;
  final int OUTPUT_VECTOR_SIZE = 1;
  final int[] LAYER_SIZES = {INPUT_VECTOR_SIZE, 10, 12, 14, 8, OUTPUT_VECTOR_SIZE};
  final ActivationFunction[] LAYER_ACTIVATIONS = {ActivationFunction.TANH};
  
  final float spawn_location_x = 400; // Where to shitout the roombas
  final float spawn_location_y = 100; 
  final float simulation_length = 2000*2; // How many frames the simulation should last for
  
  boolean visible = false; // Whether or not there are any roombas in the testing array that we can draw
  int simulation_speed = 1; // How many ms to wait between simulation steps (if visible)
  
  final int num_dusts = 150;

  //Meta parameters
  final int population_size = 30;
  final float starting_lr = 0.1f; // How big the changes we make to our mutations should be
  final int starting_mutation_rate = 1; // How many mutations we should make per mutant roomba
  final int num_simulation_samples = 5; // How many times to run the simulation for each roomba, the score will be an average of the performance.
  final int num_momentum_gens = 1; // How many generations can fail before we reset to the previous best known
  
  // Runtime variables
  ArrayList<Wall> walls;
  Dust[] dusts;
  public Roomba[] roombas_being_tested;
  public boolean currently_testing = false;
  float lr = starting_lr;
  int mutation_rate = starting_mutation_rate;

  
  public NicheBreeder (ArrayList<Wall> walls, boolean visible) {
    this.walls = walls;
    this.visible = visible;
    dusts = generate_dust(num_dusts);
  }
  
  
  // Generate an array of fresh dust
  Dust[] generate_dust(int amount) {
    Dust[] new_dusts = new Dust[amount];
    for (int i = 0; i < amount; i++) new_dusts[i] = new Dust(random(width), random(height));
    return new_dusts;
  }
  
  // Utility function because this constructor is really long
  Roomba neural_network_to_roomba(NeuralNetwork instincts) {
    return new Roomba(spawn_location_x, spawn_location_y, 40, walls, dusts, ControlMode.INSTINCT, instincts);
  }


  float calculate_roomba_score(Roomba r) {
    return r.dust_eaten - r.num_collisions*(dusts.length / 3000.0) - 3*(num_dusts - r.dust_eaten);
  }

  // Tests all the neural networks in a simulation. Sets their 'scores' based off performance
  NeuralNetwork[] test_solutions(NeuralNetwork[] solutions) {
    // Todo: Roomba internal states aren't being reset between simulation samples
    
    // Best not try and draw this array while we're overwriting it
    this.currently_testing = false;
    
    // Create a series of roomba objects
    roombas_being_tested = new Roomba[solutions.length];
    
    // Each simulation run, we will give the neural networks new bodies
    for (int i = 0; i < solutions.length; i++) {
        roombas_being_tested[i] = neural_network_to_roomba(solutions[i]);
    }
    
    // It should be safe to draw them again, now that we've finished generating Roomba objects
    // from the neural networks
    this.currently_testing = true;
    
    // Run them all through the simulation num_simulation_samples times
    for (int j = 0; j < num_simulation_samples; j++) {
      //Randomize the dust particles in the room
      this.dusts = generate_dust(num_dusts);
      
      for (int i = 0; i < simulation_length; i++) {
        if (this.visible) delay(simulation_speed);
        for (Roomba r : roombas_being_tested) {
          r.forward();
        }
      }
            
      // Each simulation run, we will give the neural networks new bodies
      for (int i = 0; i < solutions.length; i++) {
        solutions[i].score += calculate_roomba_score(roombas_being_tested[i]);
        roombas_being_tested[i] = neural_network_to_roomba(solutions[i]);
      }
    }
    
    for (int i = 0; i < solutions.length; i++)
      solutions[i].score /= num_simulation_samples;

    return solutions;
  }
  

  // Creates an array of fresh NeuralNetworks with random weights
  NeuralNetwork[] create_first_generation() {
    NeuralNetwork[] new_gen = new NeuralNetwork[population_size];
    // We'll use the same architecture for all the roombas for now  
    // This is because I intend to migrate to sexual reproduction soon (tm)                                                    
    for (int i = 0; i < population_size; i++) {
      new_gen[i] = new NeuralNetwork(LAYER_SIZES);
    }       
    return new_gen;
  }
  
    
  NeuralNetwork create_mutated_clone(NeuralNetwork n) {
    NeuralNetwork mutant = new NeuralNetwork(n);
    for (int i = 0; i < mutation_rate; i++)
      mutant.tweak(lr);
    return mutant;
  }
  
  
  NeuralNetwork[] create_next_generation(NeuralNetwork[] previous_generation) {
    NeuralNetwork[] new_gen = new NeuralNetwork[previous_generation.length];

    // Sort the solutions by score
    Arrays.sort( previous_generation, (o1, o2) -> { if (o1.score > o2.score) return -1; else if(o1.score < o2.score) return 1; else return 0; } );
    
    // The top half lives
    for (int i = 0; i < previous_generation.length / 2; i++) {
      new_gen[i] = previous_generation[i];
    }
    
    // The bottom half is replaced by the descendants of the top half
    for (int i = 0; i < previous_generation.length / 2; i++) {
      new_gen[i+previous_generation.length/2 ] = create_mutated_clone(previous_generation[i]);
    }
    
    return new_gen;
  }
  
  
  void run() {
    Float previous_best = null;
    int num_successful_gens = 0;
    int num_generations = 0;
    int num_failures_in_row = 0;

    // We'll keep track of the best generation we've made
    NeuralNetwork[] best_gen = null;
    
    // Start with a pile of random roombas
    NeuralNetwork[] p_gen = test_solutions(create_first_generation());
    
    best_gen = p_gen;
    
    while (true) {
      // Create and test a new generation
      NeuralNetwork[] n_gen = test_solutions(create_next_generation(p_gen));
      
      // Sort them by their scores (we're doing this twice for some reason...)
      Arrays.sort( n_gen, (o1, o2) -> { if (o1.score > o2.score) return -1; else if(o1.score < o2.score) return 1; else return 0; } );

      // We'll want to keep track of this
      num_generations++;

      // If we did better than the previous generation, then that's a successful generation!
      if (previous_best == null || n_gen[0].score > previous_best) {
        num_successful_gens++;
        num_failures_in_row = 0;
        previous_best = n_gen[0].score;
        best_gen = n_gen;
        print("\n--- New Best Score Found ("); print(previous_best); print(") --- \n");
      } else {
        num_failures_in_row++;
      }

      // New generation is now the old generation
      p_gen = n_gen;
      
      // Except if we just exceeded our number of momentum gens in a row
      if (num_failures_in_row > num_momentum_gens) {
        p_gen = best_gen;
        print("\n---Too many consecutive failures, going back to best gen. ---\n");
        num_failures_in_row = 0;
      }
      
      // If more than 1 in every five generations is successful, we'll raise the mutation rate
      // But if it gets waaaay too small, then this indicates making the lr smaller isn't helping 
      // the roombas evolve. Maybe they've found the best solution, but it's probably premature convergence.
      // If it's the latter raising the lr will help, if it's the former reseting the lr won't hurt.
      // (since we always add the original parents back)
      if (lr < starting_lr / 100)
        lr = starting_lr*5;
      else if ( (num_successful_gens/num_generations) > 0.2f )
        lr = lr * 2.0;
      else
        lr = lr / 2.0;

      print("-- Generation Completed --\n");
      print("Generation No.: ");
      print(num_generations);
      print("\nBest Score: ");
      print(p_gen[0].score);
      print("\nWorst Score: ");
      print(p_gen[p_gen.length-1].score);
      print("\nLearning Rate: ");
      print(lr);
      print("\nMutation Rate: ");
      print(mutation_rate);
      print("\n--------------------------\n");
    }
  }
}
