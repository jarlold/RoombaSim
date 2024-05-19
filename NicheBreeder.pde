import java.util.Arrays;
class NicheBreeder extends Thread{
  // metaparameters
  final static int simulation_steps = 2000*2;
  final int[] neural_network_shape = {4, 3, 4, 5, 4, 4};
  final int output_size = 1;
  final int pop_size = 16;
  double lr = 1d;
  
  // Runtime variables
  public Roomba[] roombas_being_tested;
  public int render_delay = 1;
  
  // Room definition
  ArrayList<ArrayList<Wall>> rooms;
  Dust[] dusts;
  ArrayList<Wall> current_room;
  int dust_spacing = 40;
    
  public NicheBreeder() {
    this.dusts = generate_dust_grid();
    rooms = get_rooms();
    this.roombas_being_tested = new Roomba[pop_size];  
  }

  public void draw() {
    for (Dust d: dusts) d.draw();
    for (Wall w: current_room) w.draw();
    for (Roomba r: roombas_being_tested) r.draw();
  }
  
  // Generate an evenly spaced grid of dust particles wxh in size
  public Dust[] generate_dust_grid() {
    Dust[] grid = new Dust[dust_spacing*dust_spacing];
    int added = 0;
    for (int i = 0; i < dust_spacing; i++) {
      for (int j = 0; j < dust_spacing; j++) {
        grid[added] = new Dust(dust_spacing/2.0f + i*dust_spacing, dust_spacing/2.0f + j*dust_spacing);
        added++;
      }
    }
    return grid;
  }
  
  public void test_solutions(NeuralNetwork[] solutions) {
    // Test them on every room
    for (ArrayList<Wall> ws : rooms) {
      // This is just so the draw thread has something pretty to look at
      current_room = ws;
      
      // We'll need new dust
      this.dusts = generate_dust_grid();
      
      // Give each neural network a roomba body we can test
      for (int i = 0; i < solutions.length; i++) {
        roombas_being_tested[i] = new Roomba(400.0f, 300.0f, solutions[i], ws, dusts);
        roombas_being_tested[i].bearing -= radians(90);
      }
        
      // Do the simulation
      for (int i = 0; i < simulation_steps; i++) {
        for (Roomba r: roombas_being_tested) {
          r.tick();
          delay(render_delay);
        }
      }
      
      // Judge the worth of their souls.
      for (Roomba r: roombas_being_tested)
        r.instincts.score += r.dusts_eaten.size() - r.num_collisions/100;
    }
  }
  
  private NeuralNetwork[] create_initial_generation() {
    //// It is MUCH better to start with entirely distinct random Roombas, but it makes it harder to debug
    //// because even if the mutations are crud, you still get decent roombas (just from the initial selection)
    //NeuralNetwork[] new_gen = new NeuralNetwork[pop_size];

    //// We will make our first roomba by shaping him out of clay
    //NeuralNetwork adam = new NeuralNetwork(neural_network_shape, output_size);
    //new_gen[0] = adam;
    
    //// Then from his rib we will form the other Roombas.
    //for (int i = 1; i < pop_size; i++) {
    //  new_gen[i] = adam.create_clone();
    //  new_gen[i].tweak(this.lr);
    //}
    
    // Alternatively we can just shotgun spray, it's way faster
    NeuralNetwork[] new_gen = new NeuralNetwork[pop_size];
    for (int i = 0; i < new_gen.length; i++)
      new_gen[i] = new NeuralNetwork(neural_network_shape, output_size);
    
    
    return new_gen;
  }
  
  private NeuralNetwork[] create_next_generation(NeuralNetwork[] previous_generation) {
    NeuralNetwork[] new_generation = new NeuralNetwork[pop_size];
    sort_solutions(previous_generation);
    for (int i = 0; i < pop_size/2; i++) {
      new_generation[i] = previous_generation[i].create_clone();
    }
    
    for (int i = 0; i < pop_size/2; i++) {
      new_generation[i + pop_size/2] = previous_generation[i].create_clone();
      new_generation[i + pop_size/2].tweak(this.lr);
      //new_generation[i+pop_size/2] = new NeuralNetwork(neural_network_shape, output_size);
    }
    return new_generation;
  }
  
  private void sort_solutions(NeuralNetwork[] solutions) {
    Arrays.sort( solutions, (o1, o2) -> { if (o1.score > o2.score) return -1; else if(o1.score < o2.score) return 1; else return 0; } );
  }
  
  public void print_log(NeuralNetwork[] current_gen, Float best_score, int num_generations) {
    print("Generation #" + Integer.toString(num_generations), "completed:\n");
    print("GOAT Score:", best_score, "\n");
    print("Best mutant:", current_gen[current_gen.length/2].score, "\n");
    print("Learning Rate:", this.lr, "\n\n");
  }
  
  public void run() {
    NeuralNetwork[] current_gen = create_initial_generation();
    Float best_score = null;
    int num_generations = 0;
    
    // Whether or not the last 5 generations were successes. Not chronological.
    int[] score_samples = new int[5]; 
    
    while (true) {
      // Test the roombas
      test_solutions(current_gen);
      
      // Keep track of the best score
      if (best_score == null || current_gen[0].score > best_score) {
        best_score = current_gen[0].score;
        score_samples[num_generations % score_samples.length ] = 1;
      } else {
        score_samples[num_generations % score_samples.length ] = 0;
      }
      
      // If at least one generation of the last 5 succeded, raise the mutation rate (until we get more failures)
      // if the mutation rate gets too small though, then raise it- or nothing will evolves
      int successes = 0;
      for (int i : score_samples) successes += i;
      if (successes >= 1)
        this.lr *= 1.1;
      else
        this.lr /= 1.1;
      
      if (this.lr < 1E-6)
        this.lr = 1;
      
      // Print the log
      print_log(current_gen, best_score, num_generations);
      
      // Make a new generations
      current_gen = create_next_generation(current_gen);
      num_generations++;
    }
    
  }
  

  
}
