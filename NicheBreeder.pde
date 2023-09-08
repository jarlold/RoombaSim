class NicheBreeder {
  ArrayList<Wall> walls;
  ArrayList<Dust> dusts;

  final int INPUT_VECTOR_SIZE = 8;
  final int OUTPUT_VECTOR_SIZE = 1;
  
  final int[] LAYER_SIZES = {8, 5, 6, 7, 4, 1};
  final ActivationFunction[] LAYER_ACTIVATIONS ={ActivationFunction.TANH};

  final int spawn_location_x = 400;
  final int spawn_location_y = 300;

  final int pop_size = 15;
  int num_timesteps = 2000;
  final int num_test_cycles = 5;
  float lr;
  int mutation_rate = 5;

  ArrayList<NeuralNetwork> current_generation;
  ArrayList<NeuralNetwork> previous_generation;

  NeuralNetwork best_roomba;
  float best_score;
  int num_generations = 0; 
  int num_successful_generations = 0;
  int num_bad_generations_row = 0;

  public NicheBreeder(ArrayList<Wall> walls, float learning_rate) {
    this.walls = walls;
    this.lr = learning_rate;
    randomize_dust(50);
  }
  
  public Roomba neural_network_to_roomba(NeuralNetwork instincts) {
    return new Roomba(spawn_location_x, spawn_location_y, 15, walls, dusts, ControlMode.INSTINCT, instincts);
  }
    

  // Not actually gaussian lol
  public NeuralNetwork gaussian_mutated_clone(NeuralNetwork initial) {
    NeuralNetwork mutated = new NeuralNetwork(initial);
    for (int i = 0 ; i < mutation_rate; i++)
      mutated.tweak(lr);
    return mutated;
  }  
  
  private void do_rechenberg_rule() {
   lr *= 0.999;
    
    if ( (float) num_successful_generations/ (float)num_generations > 1f/5f) {
      mutation_rate--;
    } else {
      mutation_rate++;
    } 
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
   // r.turn(random(0, 365));
    float total_score = 0;
    for (int k = 0; k < num_test_cycles; k++) {
      // Make a mess of my room so they can clean it up
      randomize_dust(50);
      for (int i = 0; i < num_timesteps; i++) {
        r.forward();
      }
      total_score = get_roomba_score(r);
    }
    return total_score /= num_test_cycles;
  }
  
  public float get_roomba_score(Roomba r) {
    return r.dust_eaten;
  }
  
  public float[] test_generation(ArrayList<NeuralNetwork> generation) {
    float[] scores = new float[generation.size()];
    for (int i = 0; i < generation.size(); i++)
      scores[i] = simulate_roomba_ability(generation.get(i));
     return scores;
  }
  
  
  private ArrayList<NeuralNetwork> create_initial_generation() {
    // We'll use the same architecture for all the roombas for now
    Layer[] nn_layers = {
      new Layer(INPUT_VECTOR_SIZE, 7, ActivationFunction.TANH),
      new Layer(7, 6, ActivationFunction.TANH),
      new Layer(6, 5, ActivationFunction.TANH),
      new Layer(5, OUTPUT_VECTOR_SIZE, ActivationFunction.TANH)
    };
    // We'll create our first roomba, Adam
    NeuralNetwork adam = new NeuralNetwork(nn_layers);
    // Then we'll put him out to stud (with himself)
    ArrayList<NeuralNetwork> new_gen = asexual_reproduction(adam, pop_size);
    return new_gen;
  }
  
  private void randomize_dust(int num_particles) {
   // Add some dust to our simulation
   dusts = new ArrayList<Dust>();
   for (int i = 0; i < num_particles; i ++)
     dusts.add(new Dust(random(0, 800), random(0, 600)));
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
    // For Rechenberg rule
    num_generations++;
    
    // Set him out to stud (with himself)
    ArrayList<NeuralNetwork> babies = asexual_reproduction(best_roomba, pop_size);
    
    // Now we'll test those babies with the harsh world of simulated reality.
    float[] scores = test_generation(babies);
    float generations_best_score = max(scores);
    
    // This is just so we can spy on them from the main class.
    current_generation = babies;
    
    // If one of the babies does as well or better than his father, he will inherit the throne
    if (generations_best_score >= best_score) {
      // Hurray success!
      num_successful_generations++;
      
      print("BEST SCORE: ");
      print(best_score);
      print("\n");
      num_bad_generations_row = 0;
      best_score = generations_best_score;
      for (int i = 0; i < scores.length; i++) {
        if (scores[i] == best_score) {
          best_roomba = current_generation.get(i);
          break;
        }
      }
      
    } else {
      // But if all the children are dissapointments, we'll throw them off a cliff like in 300
      current_generation = previous_generation;
      num_bad_generations_row++;
    }
    
     // We adjust the mutation rate to follow the rechenberg principle
    //do_rechenberg_rule();
    
  }
  
  public void fast_forward(int n_cycles) {
    for (int i = 0; i < n_cycles; i++) {
      genetic_algorithm_cycle();
      if (i % 100 == 0) {
        print("META ");
        print(mutation_rate);
        print(" ");
        print(lr);
        print("\n");
      }
    };
  }
  
  public void optimize_niche(int num_bad_cycles_to_break) {
    while (num_bad_generations_row < num_bad_cycles_to_break)
      genetic_algorithm_cycle();
  }

}
