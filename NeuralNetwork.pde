class NeuralNetwork {
  double[][][] weights;
  final int output_size;
  final int[] sizes;
  
  // This is used to sort the solutions later on.
  public float score = 0;
  
  public NeuralNetwork(int[] sizes, int output_size) {
    // Store the size array, for cloning mostly
    this.sizes = sizes;
    
    // Initialize the weights in accordance to the sizes array
    this.weights = new double[sizes.length][][];
    for (int i = 0; i < sizes.length-1; i++) {
      weights[i] = initialize_layer(sizes[i], sizes[i+1]);
    }
    weights[sizes.length-1] = initialize_layer(sizes[sizes.length-1], output_size);

    this.output_size = output_size;
  }
  
  public NeuralNetwork create_clone() {
    // After last time I'm not fucking around. We're clone EVERY. SINGLE. WEIGHT. EXACTLY.
    NeuralNetwork clone = new NeuralNetwork(this.sizes, this.output_size);
    for (int i = 0; i < weights.length; i++)
      for (int j = 0; j < weights[i].length; j++)
        for (int k = 0; k < weights[i][j].length; k++)
          clone.weights[i][j][k] = this.weights[i][j][k];
    return clone;
  }
  
  // I would make this static but that breaks Processing's PApplet code T_T
  public NeuralNetwork create_crossover_clone(NeuralNetwork m, NeuralNetwork f) {
    NeuralNetwork clone = new NeuralNetwork(m.sizes, m.output_size);
    int split_point = (int) random(1, m.weights.length);
    
    // Copy up to split point on the first Neural Network
    for (int i = 0; i < split_point; i++)
      for (int j = 0; j < m.weights[i].length; j++)
        for (int k = 0; k < m.weights[i][j].length; k++)
          clone.weights[i][j][k] = m.weights[i][j][k];
          
    // Copy paste paste the split point on the second Neural Network
    for (int i = split_point; i < m.weights.length; i++)
      for (int j = 0; j < f.weights[i].length; j++)
        for (int k = 0; k < f.weights[i][j].length; k++)
          clone.weights[i][j][k] = f.weights[i][j][k];
          
     return clone;
  }
  
  // Creates a guassian random matrix of shape wxh
  private double[][] initialize_layer(int w, int h) {
    double[][] l = new double[w][h];
    for (int i = 0; i < w; i++)
      for (int j = 0; j < h; j++)
        l[i][j] = random(-100, 100);
    return l;
  }
  
  public double[] forward(double[] input) {
    double[] output = input.clone();
    for (int i = 0; i < weights.length-1; i++)
      output = tanh_vector(vector_matrix_multiplication(output, this.weights[i]));
    output = vector_matrix_multiplication(output, this.weights[this.weights.length-1]);
      
    return output;
  }
  
  public void tweak(double lr) {
    double[][] rand_layer = weights[(int) random(0, weights.length)];
    rand_layer[(int) random(0, rand_layer.length)][(int) random(0, rand_layer[0].length)] += random((float) -lr, (float) lr);
  }
  
  private double[] vector_matrix_multiplication(double[] vector, double[][] matrix) {
    /*
      w1 w2  w3  w4      i1      w1 *i1 + w5 *i2 + w9  *i3
      w5 w6  w7  w8   *  i2   =  w2 *i1 + w6 *i2 + w10 *i3
      w9 w10 w11 w12     i3      w3 *i1 + w7 *i2 + w11 *i3
                                 w4 *i1 + w8 *i2 + w12 *i3
   */
    if (vector.length != matrix.length) {
      // Error handling in java is annoying so we're just gonna print this out.
      print("Warning: Inproper shapes for matrix vector multiplication.\n");
      print(matrix.length, "x", matrix[0].length, "*", vector.length);
    }
      
    // Create an array to hold the outputs, initialize everything in there as 0
    double[] output = new double[matrix[0].length];
    for (int i = 0; i < output.length; i++) output[i] = 0;
    
    // Go through the columns of the matrix
    for (int i = 0; i < output.length; i++)
      for (int j = 0; j < matrix.length; j++)
        output[i] += matrix[j][i] * vector[j];
        
    return output;
  }
  
  // performs tanh on a vector
  private double[] tanh_vector(double[] vector) {
    for (int i = 0; i < vector.length; i++)
      vector[i] = Math.tanh(vector[i]);
    return vector;
  }
  
}
