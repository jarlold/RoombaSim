
class RoombaGenerator {
 int max_layers;
 int max_layer_size;
 ArrayList<Wall> walls;
 
 final int INPUT_VECTOR_SIZE = 7;
 final int OUTPUT_VECTOR_SIZE = 1;
 
 
 public RoombaGenerator (int max_layers, int max_layer_size, ArrayList<Wall> walls) {
   this.max_layers = max_layers;
   this.max_layer_size = max_layer_size;
   this.walls = walls;
 }
 
 
 public Roomba generate_random_roomba() {
   
   Layer[] layers = new Layer[int(random(2, max_layers))];
   
   layers[0] = new Layer(INPUT_VECTOR_SIZE, int(random(1, max_layer_size)), ActivationFunction.NONE);

   for (int i = 1; i < layers.length - 1; i++) {
    layers[i] =  new Layer(layers[i-1].output_size, int(random(1, max_layer_size)), ActivationFunction.RELU);
   }
   //Kawai   
   layers[layers.length - 1] = new Layer(layers[layers.length - 2 ].output_size, OUTPUT_VECTOR_SIZE, ActivationFunction.NONE);
   
   
   NeuralNetwork nn = new NeuralNetwork(layers);
   
   color c = color(120 + random(0, 254-120), 120 + random(0, 254-120), 120 + random(0, 254-120));
   
   Roomba r = new Roomba(400.0f, 300.0f, 40.0f, c, walls, ControlMode.INSTINCT, nn);
   r.turn(random(0, 360));
   return r;
 }
  
  
  
  
}
