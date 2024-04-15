class Dust {
  float x;
  float y;
  float size = 5;
  ArrayList<Roomba> eaten_by;
  int pulse_ticks = 0;
  boolean pulsing = false;
  color pulsing_color = color(0, 255, 0);
  int color_intensity = 255;
  
  public Dust(float x, float y) {
    this.x = x;
    this.y = y;
    eaten_by = new ArrayList<Roomba>();
  }
  
  public void clear_history() {
    eaten_by = new ArrayList<Roomba>();
  }
  
  private boolean collides_with(Roomba r) {
    float our_radius = (r.size + size)/2;
    return abs(r.x - x) <= our_radius & abs(r.y - y) <= our_radius; 
  }
  
  public int try_to_eat(Roomba r) {
    if (collides_with(r)) {
      if (eaten_by.contains(r)) {
        return 0;
      } else {
        eaten_by.add(r);
        return 1;
      }
    }
    return 0;
  }
  
  public void draw() {
    fill(color(255));
    //if (pulse_ticks > 40) {
    //  pulsing = false;
    //  pulse_ticks = 0;
    //  fill(color( color_intensity < 255 ? color_intensity : 255  ));
    //} else if(pulsing) {
    //  pulse_ticks++;
    //  fill(pulsing_color);
    //}
    
    circle(x, y, size);
    fill(color(255));
  }
  
}
