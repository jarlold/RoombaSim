class Roomba {
 
    float x;
    float y;
    float size;
    color c;
    float speed;
    float bearing;
    ArrayList<Wall> walls;
    Dust[] dusts;
    float dbearing = 0;
    ControlMode player_controls;
    public NeuralNetwork instincts;
    
    
    // Settings that are based off reality lol
    float max_roomba_turn_deg = -5;
    float max_time_steps = 60*60*5; // 60 frame/s * 60s/min * 5 min/run
    
    // Metrics we'll keep track of and give to the neural network
    public float num_collisions = 0; // Don't reset this!

    float time_steps = 0;
    float ttl_collision = 0; // in frames TODO: needs to be seconds to use on real roomba
    ArrayList<Float> collision_times = new ArrayList<Float>(); // also needs conversion from frames
  
    // Meta-parameters that we'll let the genetic algorithm decide maybe idk
    int collision_lookback_period = 300;
    
    // Metrics we'll use to evaluate the success of the roomba
    ArrayList<Float> x_history = new ArrayList<Float>();
    ArrayList<Float> y_history = new ArrayList<Float>();
    
    int dust_eaten = 0; // Don't reset this either!
  
   public Roomba(float x, float y, float size, ArrayList<Wall> walls, Dust[] dusts, ControlMode pc, NeuralNetwork instincts) {
      this.x = x;
      this.y = y;
      this.size = size;
      this.c = color( (int)random(125, 255),(int)random(125, 255),(int)random(125, 255)); 
      this.speed = 1f;
      this.bearing = 0f;
      this.walls = walls;
      this.player_controls = pc;
      this.instincts = instincts;
      this.dusts = dusts;
    }
  
  
    public int get_dust_eaten() {
      return dust_eaten;
    }  
  
    public void draw() {      
      if (abs(mouseX - x) <= size & abs(mouseY - y) <= size)
        on_mouse_over();
      
      do_player_controls();
      fill(c);
      circle(x, y, size); 
      fill(255);
      circle(x+sin(bearing) * speed * 10, y + cos(bearing) * speed * 10, 10);
      fill(125, 125, 125);
    }
    
 
   public void turn(float deg) {
      this.bearing += deg * (2*PI/360);
   }


   public float[] get_input_vector() {
     /*
      We'll feed the neural network certain statistics about
      how are roomba is moving.
      We'll show it:
      - Moving average of how many collisions its had. 
      - It's current bearing (in degrees) +/- some noise
      - How long its been running for, currently in frames TODO: switch to seconds
      - Percieved x/y (x/y + some noise, maybe count misaligned when colliding?)
      - Moving average of dx/dy of the bearing (again in frames)
      - Total number of collisions
      - Time since last collision (also in frames)
      
      
      Can't show it:
      - How much of the room has been cleared (real roomba won't know)
     
      TODO:
      - Make the random-noise sometimes negative
      - Change frame based times to seconds
      - Better regularization
     
     */
     
      float[] input_vector = {
          get_num_col_moving_avg(),
          (360 * (this.bearing / 2 * PI) + random(0, 5)), //360, 
          time_steps / max_time_steps, 
          1, //-(this.x + random(0, 2*speed) - width/2) / width, 
          num_collisions,
          (time_steps - ttl_collision),
          sin(time_steps)
      };
      
       return input_vector; 
      }
     
     float get_instinctual_bearing_change() {
      float[] input_vector = get_input_vector();
      
      //TODO: This was just for debugging
      for (int i = 0; i < input_vector.length; i++)
         if (Float.isNaN(input_vector[i]))
           print(i);
      
      float instinct_bearing_change = instincts.forward(input_vector)[0] ;
      if( Float.isNaN( instinct_bearing_change * max_roomba_turn_deg )) {
        return 0f;
      } else {
        return (instinct_bearing_change ) * max_roomba_turn_deg;
      }
   }
   
   
   float get_num_col_moving_avg() {
     if (collision_times.size() <= 0) return 0f;
     
     float sum  = 0;
     for (int i = collision_times.size() -1; i > 0; i--)
       if (time_steps - collision_times.get(i) < collision_lookback_period)
         sum += 1;
        else
          break;
     
     return sum;
   }

   
   public void forward() {    
     time_steps += 1;
    
     // Record the roombas positioning for evaluation later
     if (time_steps % 2 == 0) {
         x_history.add(this.x);
         y_history.add(this.y);
     }


     // Keep track of the score so we know who to send to Android Hell
     check_dust();

    float dx = sin(bearing) * speed + random(-0.5, 0.5);
    float dy = cos(bearing) * speed + random(-0.5, 0.5);
    
    // Move in the X direction except if we collide undo that
    this.x += dx;  
   if (check_collision()) 
     this.x -= dx;
     
    //Move in the y Direction except if we collide undo that
   this.y += dy;
   if (check_collision())
       this.y -= dy;       
   }
   
   private boolean check_collision() {
     for (Wall i : walls) 
       if (i.is_roomba_colliding(this)) {
         on_collision();
         return true;
       } 
       return false;
   }
   

  private void do_player_controls() {
    switch(this.player_controls) {
      case MOUSE:     
        float dx = this.x - mouseX;
        float dy = this.y - mouseY;
        this.bearing = PI + atan2( dx, dy);
      break;
      
      case KEYBOARD:
        if (keyPressed) {
          if (keyCode == LEFT)
            this.turn(4f);
    
            
          if (keyCode == RIGHT) 
            this.turn(4f);
        }
      break;
      
      case INSTINCT:
        this.turn(get_instinctual_bearing_change());
      break;
    }
  }
  
  void on_mouse_over() {
    
    fill( color(255, 255, 255));
    rect(0, 0, 300, 200);
    float[] iv = get_input_vector();
    
    
    fill( color(0, 0, 0));
    for (int i = 0; i < iv.length; i++)
      text(str(iv[i]), 10, 20*i);
    
    textSize(20);    
  }
  
  
  private void on_collision() {  
     num_collisions += 1;
     ttl_collision = time_steps;
     collision_times.add(
       time_steps * 1
     );
  }
  
  private void check_dust() {
    for (Dust d : dusts) {
      dust_eaten += d.try_to_eat(this);
    }
  }
  

}
