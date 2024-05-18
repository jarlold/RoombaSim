class Dust {
  float x, y;
  
  public Dust(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  public void draw() {
    fill(255);
    circle(x, y, 4);
  }
  
  public boolean collides(Roomba r) {
    return pow(r.x - this.x, 2) + pow(r.y - this.y, 2) < pow(r.radius, 2);
  }

}
