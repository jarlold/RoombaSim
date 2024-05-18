import java.util.Arrays;
class NicheBreeder extends Thread{
  // metaparameters
  final int simulation_steps = 2000*4;
  final int[] neural_network_shape = {4, 3, 4, 5, 4, 4};
  final int output_size = 2;
  final int pop_size = 20;
  double lr = 1d;
  
  // Runtime variables
  public Roomba[] roombas_being_tested;
  public int render_delay = 10;
  
  // Room definition
  ArrayList<Wall> walls;
  Dust[] dusts;
    
  public NicheBreeder(ArrayList<Wall> walls) {
    this.dusts = generate_dust_grid(width/40, height/40, 40);
    this.walls = walls;
    this.roombas_being_tested = new Roomba[pop_size];  
  }

  public void draw() {
    for (Dust d: dusts) d.draw();
    for (Wall w: walls) w.draw();
    for (Roomba r: roombas_being_tested) r.draw();
  }
  
  // Generate an evenly spaced grid of dust particles wxh in size
  public Dust[] generate_dust_grid(int w, int h, float every) {
    Dust[] grid = new Dust[w*h];
    int added = 0;
    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        grid[added] = new Dust(every/2 + i*every, every/2 + j*every);
        added++;
      }
    }
    return grid;
  }
  
  public void test_solutions(NeuralNetwork[] solutions) {
    // Give each neural network a roomba body we can test
    for (int i = 0; i < solutions.length; i++) 
      roombas_being_tested[i] = new Roomba(50.0f, 50.0f, solutions[i], walls, dusts);
      
    // Do the simulation
    for (int i = 0; i < simulation_steps; i++) {
      for (Roomba r: roombas_being_tested) {
        r.tick();
        delay(render_delay);
      }
    }
    
    // Judge the worth of their souls.
    for (Roomba r: roombas_being_tested)
      r.instincts.score = r.dusts_eaten.size() - r.num_collisions/100;
  }
  
  private NeuralNetwork[] create_initial_generation() {
    NeuralNetwork adam = new NeuralNetwork(neural_network_shape, output_size);
    NeuralNetwork[] new_gen = new NeuralNetwork[pop_size];
    new_gen[0] = adam;
    for (int i = 1; i < pop_size; i++) {
      new_gen[i] = adam.create_clone();
      new_gen[i].tweak(this.lr);
    }
    
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
    }
    return new_generation;
  }
  
  private void sort_solutions(NeuralNetwork[] solutions) {
    Arrays.sort( solutions, (o1, o2) -> { if (o1.score > o2.score) return -1; else if(o1.score < o2.score) return 1; else return 0; } );
  }
  
  public void print_log(NeuralNetwork[] current_gen, Integer best_score, int num_generations) {
    print("Generation #" + Integer.toString(num_generations), "completed:\n");
    print("GOAT Score:", best_score, "\n");
    print("Best mutant:", current_gen[current_gen.length/2].score, "\n");
    print("Learning Rate:", this.lr, "\n\n");
  }
  
  public void run() {
    NeuralNetwork[] current_gen = create_initial_generation();
    Integer best_score = null;
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
      
      // If at least one generation of the last 5 succeded, raise the mutation rate.
      int successes = 0;
      for (int i : score_samples) successes += i;
      if (successes >= 1)
        this.lr *= 1.1;
      else
        this.lr /= 1.1;
      
      // Print the log
      print_log(current_gen, best_score, num_generations);
      
      // Make a new generations
      current_gen = create_next_generation(current_gen);
      num_generations++;
    }
    
  }
  

  
}
