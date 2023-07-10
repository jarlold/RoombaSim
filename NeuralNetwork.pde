class NeuralNetwork {
 
  Layer[] layers;
  
  public NeuralNetwork(int[] layer_sizes, ActivationFunction[] layer_activations) {
    for (int i = 0; i < layer_sizes.length - 1; i++)
      layers[i] = new Layer(layer_sizes[i], layer_sizes[i+1], layer_activations[i]);
  }
    

  
 public NeuralNetwork(Layer[] layers) {
   this.layers = layers; 
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
  
}
