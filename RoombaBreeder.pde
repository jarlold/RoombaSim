class RoombaBreeder {
 int max_layers = 12;
 int max_layer_size = 30;
 ArrayList<Wall> walls;
 
 final int INPUT_VECTOR_SIZE = 8;
 final int OUTPUT_VECTOR_SIZE = 1;
 
 float lr = 0.5;
  
  public RoombaBreeder(ArrayList<Wall> walls, float learning_rate) {
   this.walls = walls; 
   this.lr = learning_rate;
  }
  
  
  ArrayList<Roomba> select_roombas(ArrayList<Roomba> roombas) {
    ArrayList<Roomba> best_roombas = new ArrayList<Roomba>();
    
    float avg_roomba_score = 0f;
    
    for (Roomba r : roombas)
      avg_roomba_score += r.get_score();
      
    avg_roomba_score /= roombas.size();
   // avg_roomba_score *= 0; 
    
    for (Roomba r: roombas)
      if (r.get_score() >= avg_roomba_score)
        best_roombas.add(r);
    
    return best_roombas;
  }
  
  
  
  Roomba clone_roomba(Roomba a) {
    NeuralNetwork instincts = a.instincts;
    for (int i =0; i < 100; i++)
        instincts.tweak(lr);
    
    color c = color(120 + random(0, 254-120), 120 + random(0, 254-120), 120 + random(0, 254-120));
   
    Roomba r = new Roomba(50f, 50.0f, 40.0f, c, walls, ControlMode.INSTINCT, instincts);
    r.turn(random(0, 360));
    
    return r;
  }
  
 
 public Roomba generate_random_roomba() {
   Layer[] layers = new Layer[int(random(2, max_layers))];
   
   layers[0] = new Layer(INPUT_VECTOR_SIZE, int(random(1, max_layer_size)), ActivationFunction.SIGMOID);

   for (int i = 1; i < layers.length - 1; i++) {
    layers[i] =  new Layer(layers[i-1].output_size, int(random(1, max_layer_size)), ActivationFunction.RELU);
   }
   
   //Kawai   
   layers[layers.length - 1] = new Layer(layers[layers.length - 2 ].output_size, OUTPUT_VECTOR_SIZE, ActivationFunction.NONE);
   
   
   NeuralNetwork nn = new NeuralNetwork(layers);
   
   color c = color(120 + random(0, 254-120), 120 + random(0, 254-120), 120 + random(0, 254-120));
   
   Roomba r = new Roomba(50f, 50.0f, 40.0f, c, walls, ControlMode.INSTINCT, nn);
   r.turn(random(0, 360));
   return r;
 }
 
 public ArrayList<Roomba> generate_random_generation(int size) {
   ArrayList<Roomba> roombas = new ArrayList<Roomba>();
   for (int i = 0; i < size; i++)
     roombas.add(generate_random_roomba());
   return roombas;
 }
  
  
  public ArrayList<Roomba> generate_next_generation(ArrayList<Roomba> generation) {
   ArrayList<Roomba> best_roombas = select_roombas(generation);
   ArrayList<Roomba> new_gen = new ArrayList<Roomba>();
   
   this.lr = 0.95 * this.lr;
   
   
   for (Roomba i : best_roombas) {
     Roomba r = new Roomba(50f, 50.0f, 40.0f, i.c, walls, ControlMode.INSTINCT, i.instincts);
     r.turn(random(0, 360));
     new_gen.add(r);
     new_gen.add(clone_roomba(i));
     if (new_gen.size() >= generation.size())
       break;
   } 
   
   int l = (generation.size() - new_gen.size())/2;
   for (int i = 0; i < l; i++) {
     new_gen.add(clone_roomba(best_roombas.get(floor(random(0, best_roombas.size())))));
   }
   
   return new_gen;
  }
  
}
