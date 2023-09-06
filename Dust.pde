class Dust {
  float x;
  float y;
  float size = 5;
  ArrayList<Roomba> eaten_by;
  
  public Dust(float x, float y) {
    this.x = x;
    this.y = y;
    eaten_by = new ArrayList<Roomba>();
  }
  
  public void clear_history() {
    eaten_by = new ArrayList<Roomba>();
  }
  
  public boolean collides_with(Roomba r) {
    float our_radius = r.size + size;
    return !eaten_by.contains(r) & abs(r.x - x) <= our_radius & abs(r.y - y) <= our_radius; 
  }
  
  public boolean try_to_eat(Roomba r) {
    if (collides_with(r)) {
      eaten_by.add(r);
      return true;
    } else {
    return false;
    }
  }
  
  public void draw() {
    circle(x, y, size);
  }
  
}
