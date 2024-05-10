class NeuralNetwork {
 
  Layer[] layers;
    
  // This is only here because sorting things in java is annoying
  public float score;
    
 public NeuralNetwork(int[] layer_sizes) {
    layers = new Layer[layer_sizes.length-1];                                                                       
    for (int i = 0; i < layer_sizes.length-1; i++) { // -1 because the last size is actually useless (its the output layer size
       layers[i] = new Layer(layer_sizes[i], layer_sizes[i+1], ActivationFunction.TANH);                                    
    } 
 }
    
  public NeuralNetwork(Layer[] layers) {
   this.layers = layers; 
  }
  
  public NeuralNetwork(NeuralNetwork clone_me) {
    this.layers = clone_me.layers.clone();
  }

    
  public float[] forward(float[] in) {
       float[] working = in;
       for (Layer l : this.layers) 
         working = l.forward(working);
       return working;
    }
    
    
  public void tweak(float lr) {
    // Modify a weight by some random amount
    int l = int(random(0, layers.length));
    layers[l].tweak(lr);
    
    // Choose to randomly drop or add a layer
    //boolean drop = (int(random(0, 1)) == 0);
  }
  
  public float[][][] get_as_matrix() {
    float[][][] matrix = new float[layers.length][][];
    for (int i = 0 ; i < layers.length; i++) {
      matrix[i] = layers[i].get_weights();
    }
    return matrix;
  }
  
  float get_distance(NeuralNetwork o) {
    // I'm not really sure about this distancing function, I wrote it in DB class bc i was bored
    // It follows the simple constraints below:
    // - Distance(me, me) == 0
    // - Distance(me, 2*me) < Distance(me, 3*me)
    // I think it'll do the trick but I don't think it's perfect
  
     // S = nxnxn matrix
     // O = nxnxn matrix
     float[][][] our_matrix = this.get_as_matrix();
     float[][][] other_matrix = o.get_as_matrix();
     
     // Sum of difference of squares for each element in the matrix. squared
     // Don't mind me I'm just gonna triple iterate real quick \(X_X \) !!!
     float sum = 0;
     for (int i = 0; i < other_matrix.length; i++)
       for (int j = 0; j < other_matrix[i].length; j++)
         for(int k = 0; k < other_matrix[i][j].length; k++)
           sum += pow(other_matrix[i][j][k] - our_matrix[i][j][k], 2);
           
           
      // This is all equivalent to if we flattened out both matrices and then did
      // dist = sqrt( (a1 -b1)^2 + (a2 - b2)^2 ... (an - bn)^2 )
      // Like a REALLY BIG euclidean distance of 2 long ass 1d matrices
      return sqrt(sum);
  }

  
  void draw(float x, float y, float scale) {
   float centre_y = (layers[0].input_size * scale * 1.25)/2;
   for (int j = 0; j < layers[0].input_size; j++) {
      circle(x + scale * 4 * -1, y - j * scale * 1.25 + centre_y, scale); 
   }
    
    for (int i =0; i < layers.length; i++) {       
        // Draw the circles that represent our nodes
        centre_y = (layers[i].output_size * scale * 1.25)/2;
        for (int j = 0; j < layers[i].output_size; j++) {
           circle(x + scale * 4 * i, y - j * scale * 1.25 + centre_y, scale); 
        }
    }
    
 }
 
 public String toString() {
  String output = "LAYERS:\n"; // Windows users can eat my shorts \n for life \n gang 
  
  // First we'll output the structure of the network. This could be inferred, but its not much data and
  // will make reading the neural network back much easier.
  for (Layer l : this.layers)
    output += "HIDDEN LAYER " + l.getActivationFunctionName() + " " + Integer.toString(l.weights.length) + " " + Integer.toString(l.weights[0].length) + "\n";
  
  // Now we'll print out their actual values
  output += "\nWEIGHTS\n";
  
  // Then print out the weights something like this:
  // 1 1 1 1 1 1 | 2 2 2 2 2 | 3333
  // 4 4 4 4 4 4 4 4 | 5 5 5 5 5 5 | 3 3
  // Except thats not a valid network shape but you get the idea, right?
  for (Layer l : this.layers) {
    for (float[] weights : l.weights) {
      for (float w : weights)
        output += " " + Float.toString(w);
      output += "\n";
    }
    output += "\n\n";
  }
  return output;
 }
 
 public void save(String filepath) {
   String[] cont = new String[1];
   cont[0] = this.toString();
   saveStrings(filepath, cont);
 }
  
}
