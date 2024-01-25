import java.util.Arrays;
class NicheBreeder extends Thread {
  
  // Basic Settings
  final int INPUT_VECTOR_SIZE = 8;
  final int OUTPUT_VECTOR_SIZE = 1;
  final int[] LAYER_SIZES = {INPUT_VECTOR_SIZE, 5, 6, 7, 4, OUTPUT_VECTOR_SIZE};
  final ActivationFunction[] LAYER_ACTIVATIONS ={ActivationFunction.TANH};
  
  final float spawn_location_x = 400; // Where to shitout the roombas
  final float spawn_location_y = 100; 
  final float simulation_length = 200; // 2000*2; // How many frames the simulation should last for
  
  boolean visible = false; // Whether or not there are any roombas in the testing array that we can draw

  //Meta parameters
  final int population_size = 30;
  final float starting_lr = 0.1f;
  final int num_simulation_samples = 5; // How many times to run the simulation for each roomba, the score will be an average of the performance.
  
  // Runtime variables
  ArrayList<Wall> walls;
  float lr = starting_lr;
  Dust[] dusts;
  public Roomba[] roombas_being_tested;
  public boolean currently_testing = false;
  
  public NicheBreeder (ArrayList<Wall> walls, boolean visible) {
    this.walls = walls;
    this.visible = visible;
    dusts = generate_dust(50);
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


  // Tests all the neural networks in a simulation. Sets their 'scores' based off performance
  NeuralNetwork[] test_solutions(NeuralNetwork[] solutions) {
    // Best not try and draw this array while we're overwriting it
    this.currently_testing = false;
    
    // Create a series of roomba objects
    roombas_being_tested = new Roomba[solutions.length];
    for (int i = 0; i < solutions.length; i++) {
      roombas_being_tested[i] = neural_network_to_roomba(solutions[i]);
    }
    
    // It should be safe to draw them again, now that we've finished generating Roomba objects
    // from the neural networks
    this.currently_testing = true;
    
    // Run them all through the simulation num_simulation_samples times
    for (int j = 0; j < num_simulation_samples; j++) {
      for (int i = 0; i < simulation_length; i++) {
        if (this.visible) delay(10);
        for (Roomba r : roombas_being_tested) {
          r.forward();
        }
      }
    }
    
    // Then based off that, ascribe their scores to the neural networks that were piloting them
    for (int i = 0; i < solutions.length; i++)
      solutions[i].score = -roombas_being_tested[i].num_collisions / num_simulation_samples;
      
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
    NeuralNetwork[] p_gen = test_solutions(create_first_generation());
    do {
      NeuralNetwork[] n_gen = test_solutions(create_next_generation(p_gen));
      Arrays.sort( n_gen, (o1, o2) -> { if (o1.score > o2.score) return -1; else if(o1.score < o2.score) return 1; else return 0; } );

      p_gen = n_gen;

      print("Generation's Results:\n");
      for (int i = 0; i < population_size; i++) {
        print(p_gen[i].score);
        print("\n");
      }
      print("-----\n");
    } while (true);
  }
}
