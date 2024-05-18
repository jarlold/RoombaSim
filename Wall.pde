class Wall {
  float x, y, w, h;
  
  public Wall(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  public void draw() {
    rect(x, y, w, h);
  }
  
  public boolean collides(Roomba r) {
    float px = r.x;
    float py = r.y;
    px = max(px, this.x);
    px = min(px, this.x + this.w);
    py = max(py, this.y);
    py = min(py, this.y + this.h);
    
    return pow((r.y - py), 2) + pow(r.x - px, 2) < pow(r.radius, 2);
  }
  
  
}
