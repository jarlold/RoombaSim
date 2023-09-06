class RoombaBreeder {
  int max_layers = 12;
  int max_layer_size = 30;
  ArrayList<Wall> walls;

  final int INPUT_VECTOR_SIZE = 8;
  final int OUTPUT_VECTOR_SIZE = 1;
  
  final int[] LAYER_SIZES = {8, 5, 6, 7, 4, 1};
  final ActivationFunction[] LAYER_ACTIVATIONS ={ActivationFunction.TANH};

  final int spawn_location_x = 400;
  final int spawn_location_y = 300;

  final int num_timesteps = 5000;
  final int num_test_cycles = 10;
  float lr = 0.5;

  ArrayList<NeuralNetwork> current_generation;
  ArrayList<NeuralNetwork> previous_generation;

  NeuralNetwork best_roomba;
  float best_score;

  public RoombaBreeder(ArrayList<Wall> walls, float learning_rate) {
    this.walls = walls;
    this.lr = learning_rate;
  }
  
  public Roomba neural_network_to_roomba(NeuralNetwork instincts) {
    return new Roomba(spawn_location_x, spawn_location_y, 15, walls, ControlMode.INSTINCT, instincts);
  }
    

  public NeuralNetwork gaussian_mutated_clone(NeuralNetwork initial) {
    NeuralNetwork mutated = new NeuralNetwork(initial);
    mutated.tweak(lr);
    return mutated;
  }  
  
  public ArrayList<NeuralNetwork> asexual_reproduction(NeuralNetwork daddy, int num_babies) {
    ArrayList<NeuralNetwork> babies = new ArrayList<NeuralNetwork>();
    for (int i = 0; i < num_babies; i++) {
      babies.add(
        gaussian_mutated_clone(daddy)
      );
    }
    return babies;
  }


  public float simulate_roomba_ability(NeuralNetwork instincts) {
    Roomba r = neural_network_to_roomba(instincts);
    float total_score = 0;
    for (int k = 0; k < num_test_cycles; k++) {
      for (int i = 0; i < num_timesteps; i++) {
        r.forward();
      }
      total_score = r.get_score();
    }
    return total_score /= num_test_cycles;
  }
  
  public float[] test_generation(ArrayList<NeuralNetwork> generation) {
    float[] scores = new float[generation.size()];
    for (int i = 0; i < generation.size(); i++)
      scores[i] = simulate_roomba_ability(generation.get(i));
     return scores;
  }
  
  
  public ArrayList<NeuralNetwork> create_initial_generation() {
    // We'll use the same architecture for all the roombas for now
    Layer[] nn_layers = {
      new Layer(INPUT_VECTOR_SIZE, 7, ActivationFunction.SIGMOID),
      new Layer(7, 6, ActivationFunction.TANH),
      new Layer(6, 5, ActivationFunction.TANH),
      new Layer(5, OUTPUT_VECTOR_SIZE, ActivationFunction.RELU)
    };
    // We'll create our first roomba, Adam
    NeuralNetwork adam = new NeuralNetwork(nn_layers);
    // Then we'll put him out to stud (with himself)
    ArrayList<NeuralNetwork> new_gen = asexual_reproduction(adam, 20);
    return new_gen;
  }
  
  public void initialize_genetic_algorithm() {    
    // We'll start by making some totally random roombas out of clay.
    // Roombas don't have ribs, so ours will be asexual
    current_generation = create_initial_generation();
    
    // Then, as God does, we will test their faith.
    float[] scores = test_generation(current_generation);
    
    // They will set the starting standard for all roombas to come
    best_score = max(scores);
    
    // And we'll put him on a pedestal for all to admire
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] == best_score) {
        best_roomba = current_generation.get(i);
        break;
      }
    }
    
    // And now they become the old timers
    previous_generation = current_generation;
  }
  
  // Does one step in the genetic algorithm
  public void genetic_algorithm_cycle() {
    // Set him out to stud (with himself)
    ArrayList<NeuralNetwork> babies = asexual_reproduction(best_roomba, 15);
    
    // Now we'll test those babies with the harsh world of simulated reality.
    float[] scores = test_generation(babies);
    float generations_best_score = max(scores);
    
    // This is just so we can spy on them from the main class.
    current_generation = babies;
    
    // If one of the babies does as well or better than his father, he will inherit the throne
    if (generations_best_score >= best_score) {
      best_score = generations_best_score;
      for (int i = 0; i < scores.length; i++) {
        if (scores[i] == best_score) {
          best_roomba = current_generation.get(i);
          break;
        }
      }
      // And everytime we have a success, we'll lower the learning rate by a little bit
      lr = 0.95 * lr;
    } else {
      // But if all the children are dissapointments, we'll throw them off a cliff like in 300
      current_generation = previous_generation;
    }
    
  }
  
  public void fast_forward(int n_cycles) {
    for (int i = 0; i < n_cycles; i++) genetic_algorithm_cycle();
  }

}
