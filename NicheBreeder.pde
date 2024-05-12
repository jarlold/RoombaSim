import java.util.Arrays;
class NicheBreeder extends Thread {
  
  // Basic Settings
  final int INPUT_VECTOR_SIZE = 7;
  final int OUTPUT_VECTOR_SIZE = 1;
  final int scale_factor = 1; // for playing around with the size of the neural network
  final int[] LAYER_SIZES = {INPUT_VECTOR_SIZE, 10*scale_factor, 12*scale_factor, 14*scale_factor, 8*scale_factor, OUTPUT_VECTOR_SIZE};
  final ActivationFunction[] LAYER_ACTIVATIONS = {ActivationFunction.TANH};
  
  final float spawn_location_x = 400; // Where to shitout the roombas
  final float spawn_location_y = 100; 
  final float simulation_length = 2000*4; // How many frames the simulation should last for
  
  boolean visible = false; // Whether or not there are any roombas in the testing array that we can draw
  int simulation_speed = 2; // How many ms to wait between simulation steps (if visible)
  
  //Meta parameters
  final int break_after_n_generations = 1000000;
  final int population_size = 2; //250;
  final float starting_lr = 10f; // How big the changes we make to our mutations should be
  final int starting_mutation_rate = 200; // How many mutations we should make per mutant roomba
  final int num_simulation_samples = 1; // How many times to run the simulation for each roomba, the score will be an average of the performance.
  final int num_momentum_gens = 5; // How many generations can fail before we reset to the previous best known
  
  // Runtime variables
  ArrayList<Wall> walls;
  ArrayList<ArrayList<Wall>> rooms;
  Dust[] dusts;
  public Roomba[] roombas_being_tested;
  public boolean currently_testing = false;
  float lr = starting_lr;
  int mutation_rate = starting_mutation_rate;
  
  public NicheBreeder (ArrayList<ArrayList<Wall>> rooms, boolean visible) {
    this.rooms = rooms;
    this.visible = visible;
    dusts = generate_dust();
  }
  
  
  // Generate an array of fresh dust
  Dust[] generate_dust() {
    int added = 0;
    int frequency = 40;
    Dust[] new_dusts = new Dust[(width/frequency)*(height/frequency)];
    for (int i = 0; i < width/frequency; i++) {
      for (int j = 0; j < height/frequency; j++) {
        new_dusts[added] = new Dust(frequency*i, frequency*j);
        added++;
      }
    }
    return new_dusts;
  }
  
  // Utility function because this constructor is really long
  Roomba neural_network_to_roomba(NeuralNetwork instincts) {
    if (this.walls == null) print("");
    return new Roomba(spawn_location_x, spawn_location_y, 40, walls, dusts, ControlMode.INSTINCT, instincts);
  }


  float calculate_roomba_score(Roomba r) {
    return r.dust_eaten - r.num_collisions/10000;
  }

  // Sort solutions by their score, requires them to already be tested
  void sort_solutions(NeuralNetwork[] solutions) {
     Arrays.sort( solutions, (o1, o2) -> { if (o1.score > o2.score) return -1; else if(o1.score < o2.score) return 1; else return 0; } );
  }

  // Tests all the neural networks in a simulation. Sets their 'scores' based off performance
  NeuralNetwork[] test_solutions(NeuralNetwork[] solutions) {    
    float[] solution_scores = new float[solutions.length];
    
    // Best not try and draw this array while we're overwriting it
    this.currently_testing = false;
    
    // Create a series of roomba objects
    roombas_being_tested = new Roomba[solutions.length];
        
    // It should be safe to draw them again, now that we've finished generating Roomba objects
    // from the neural networks
    this.currently_testing = true;
    float random_turning;
    
    //TODO: Jarlold rolls worst `quadruple iteration`. Asked to leave `room cycle rotation`. (its slow fix it somehow)
    // Run them all through the simulation num_simulation_samples times
    for (int j = 0; j < num_simulation_samples; j++) {
      random_turning = radians(random(0, 360));
      // And each cycle we'll test them on each of the rooms...
      for (ArrayList<Wall> room : rooms) {
        this.walls = room; // We'll set this to point to the current room so the draw thread can find it
      
        // Each simulation run, we will give the neural networks new bodies
        for (int i = 0; i < solutions.length; i++) {
            roombas_being_tested[i] = neural_network_to_roomba(solutions[i]);
            //roombas_being_tested[i].bearing += random_turning;
        }
      
        //Randomize the dust particles in the room
        this.dusts = generate_dust();
        
        // Finally run the actual simulation (We'll run through each roomba in parallel)
        for (int i = 0; i < simulation_length; i++) {
          if (this.visible) delay(simulation_speed);
          for (Roomba r : roombas_being_tested) {
            r.forward();
          }
        }
              
        // Write down their scores before purging their bodies of this mortal world
        for (int i = 0; i < solutions.length; i++) {
          solution_scores[i] += calculate_roomba_score(roombas_being_tested[i]);
        }
      }
    }
    
    // Average the score out accross the number of simulations we sampled.
    // Not actually helpful to the algorithm, but it lets us understand the outputs
    // better. We in theory could divide before printing, but then I'd have to do it when
    // things crash and I don't want to.
    for (int i = 0; i < solutions.length; i++)
      solutions[i].score = solution_scores[i] / num_simulation_samples;

    return solutions;
  }
  

  // Creates an array of fresh NeuralNetworks with random weights
  NeuralNetwork[] create_first_generation() {
    NeuralNetwork[] new_gen = new NeuralNetwork[population_size];
    NeuralNetwork adam = new NeuralNetwork(LAYER_SIZES);
    // We'll use the same architecture for all the roombas for now  
    // This is because I intend to migrate to sexual reproduction soon (tm)                                                    
    for (int i = 0; i < population_size; i++) {
      new_gen[i] = new NeuralNetwork(adam);
    }       
    return new_gen;
  }
  
    
  NeuralNetwork create_mutated_clone(NeuralNetwork n) {
    NeuralNetwork mutant = new NeuralNetwork(n);
    for (int i = 0; i < mutation_rate; i++)
      mutant.tweak(lr);
    return mutant;
  }
  
  // ROOMBA SEX ROOMBA SEX ROOMBA SEX ROOMBA SEX
  //NeuralNetwork create_offspring(NeuralNetwork m, NeuralNetwork f) {
    
  //}
  
  
  NeuralNetwork[] create_next_generation(NeuralNetwork[] previous_generation) {
    NeuralNetwork[] new_gen = new NeuralNetwork[previous_generation.length];

    // Sort the solutions by score
    // this should be done before the array gets to this function
    //sort_solutions(previous_generation);
    
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
    int moment_gens_used = 0;        // This variable and the one below it are almost the same
    int gens_since_last_success = 0; // except "momentum gens used" gets reset to 0 when we return to previous best known gen.

    // We'll keep track of the best generation we've made
    NeuralNetwork[] best_gen = null;
    
    // Start with a pile of random roombas
    NeuralNetwork[] p_gen = test_solutions(create_first_generation());
    
    // Just for setting some initial parameters, we can sort this thing twice it doesn't matter
    sort_solutions(p_gen);
    previous_best = p_gen[0].score;
    best_gen = p_gen;
    
    while (true) {
      // Create and test a new generation
      NeuralNetwork[] n_gen = test_solutions(create_next_generation(p_gen));
      
      // Sort them by their scores
      sort_solutions(n_gen);

      // We'll want to keep track of this
      num_generations++;

      // If we did better than the previous generation, then that's a successful generation!
      if ( n_gen[0].score > previous_best) {
        num_successful_gens++;
        moment_gens_used = 0;
        gens_since_last_success = 0;
        previous_best = n_gen[0].score;
        
        // We have to actually clone the new generation or it'll just be a pointer to it and we'll slowly corrupt
        // it each iteration
        //best_gen = new NeuralNetwork[n_gen.length];
        //for (int i = 0; i < n_gen.length; i++) best_gen[i] = new NeuralNetwork(n_gen[i]);
        
        print("\n--- New Best Score Found ("); print(previous_best); print(") --- \n");
      } else {
        moment_gens_used++;
        gens_since_last_success++;
      }
            
      // New generation is now the old generation
      p_gen = n_gen;
      
      // Print out the status of the genetic algorithm after each generation
      print("-- Generation Completed --\n");
      print("Generation No.: ");
      print(num_generations);
      print("\nGen. Best Score: ");
      print(n_gen[0].score);
      print("\nWorst Score: ");
      print(n_gen[p_gen.length-1].score);
      print("\nLearning Rate: ");
      print(lr);
      print("\nMutation Rate: ");
      print(mutation_rate);
      print("\nGens Since Success: ");
      print(gens_since_last_success);
      print("\n--------------------------\n");
      
      // If more than 1 in every five generations is successful, we'll raise the mutation rate
      // If not we'll lower it to get some finer detail
     if ( (num_successful_gens/num_generations) > 0.2f )
        lr = lr * 1.1f; //2
      else
        lr = lr * 0.9f; //0.5f;
        
      // But if it gets waaaay too small, then this indicates making the lr smaller isn't helping 
      // the roombas evolve. Maybe they've found the best solution, but it's probably premature convergence.
      // If it's the latter raising the lr will help, if it's the former reseting the lr won't hurt (because of ratcheting)
      if (lr < 0.0001) // Let's not pretend floating point multiplication isn't cringe--
         lr = 0.01f; // Just fuck my shit up bro just make it shitty.
        
      // If we use up all our momentum generations, then we reset back to the best generation we know
      //if (moment_gens_used > num_momentum_gens) {
      //  print("--- Exceeded Maximum Momentum Gens. Resetting... ---\n");
      //  moment_gens_used = 0;
      //  p_gen = new NeuralNetwork[n_gen.length];
      //  for (int i = 0; i < n_gen.length; i++) p_gen[i] = new NeuralNetwork(best_gen[i]);
      //}
        
      // And of course if we hit the maximum number of generations stop the simulations
      if ( num_generations > break_after_n_generations) {
        print("\n--- Stopping Simulation ---\n");
        break;
      }
    }
    
    print("\n--- Simulation Completed ---");
    print("\nFinal Best Score: "); print(previous_best);
    print("\nTotal No. Generations: "); print(num_generations);
    print("\n--------------------------");
    
    while (true) test_solutions(best_gen);
  }
}
