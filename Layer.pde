class Layer {
  ActivationFunction activ_func;
  public float[][] weights;
  public int input_size;
  public int output_size; 
  
  public Layer (int input_size, int output_size, ActivationFunction activ_func) {
    
    this.input_size = input_size;
    this.output_size = output_size;
    
    // IDK a better way to do this in Java than with an Enum so...
    this.activ_func = activ_func; 
   
    // Initialize our empty weight matrix
    this.weights = new float[output_size][input_size];
   
     // Start with random weights
     for (int i = 0; i < output_size; i++) {
       for (int j = 0; j < input_size; j++) {
          this.weights[i][j] = randomGaussian()*100;
       }
    }
  }
  
  public Layer (Layer clone_me) {
    this.weights = clone_me.weights.clone();
    this.input_size = clone_me.input_size;
    this.output_size = clone_me.output_size;
    this.activ_func = clone_me.activ_func;
  }
  
  
  float[] forward(float[] in) {
    float[] sums = new float[output_size];
    
    /*
     This isn't how matrix-vector multiplication is done but i forget what it's actually called
     currently i am drunk. This is what i want it to do: <3 - Dumpling 
    
      w1 w2  w3  w4      i1      w1 *i1 + w5 *i2 + w9  *i3
      w5 w6  w7  w8   *  i2   =  w2 *i1 + w6 *i2 + w10 *i3
      w9 w10 w11 w12     i3      w3 *i1 + w7 *i2 + w11 *i3
                                 w4 *i1 + w8 *i2 + w12 *i3
                                 
    Wait not this is matrix vector multiplication yeah.
    */
    for (int i = 0; i < output_size; i++) {
       float[] w = weights[i];
       sums[i] = 0; 

       for (int j =0; j < input_size; j++) {
         sums[i] +=  w[j] * in[j] ;
       }
    }
    
    return activation_function(sums); // Iterates twice, inefficient TODO:
    
  }
  
  
  float[] activation_function(float[] in) {
     float[] out = in;
     for (int i = 0; i < in.length; i++) {
        switch (activ_func) {
         case SIGMOID:
            out[i] =  (float) (1 / (1 + Math.pow(Math.E, (-1 * out[i]))));
         break;
         
         case TANH:
            out[i] = (float) Math.tanh(out[i]);
         break;
         
         case RELU:
            out[i] = out[i] > 0 ? out[i] : 0;
         break;
         
         case NONE:
           out[i] = out[i];
         break;
        }
     }
     
     return out;
  }


  public void tweak(float lr) {
    int i = int(random(0, output_size));
    int j = int(random(0, input_size));
    this.weights[i][j] += random(-lr, lr);
  }

  public float[][] get_weights() {
    return this.weights;
  }
  
  public String getActivationFunctionName() {
    if (this.activ_func == ActivationFunction.TANH)
      return "TANH";
    else if (this.activ_func == ActivationFunction.SIGMOID)
      return "SIGMOID";
    else if (this.activ_func == ActivationFunction.RELU)
      return "RELU";
    else
      return "NONE";
  }
  
}
