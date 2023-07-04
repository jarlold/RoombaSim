class Wall {
  float x, y, w, h;
  
  public Wall(float x, float y, float w, float h) {
     this.x = x;
     this.y = y;
     this.w = w;
     this.h = h;
  }
 
  
  public boolean is_roomba_colliding(Roomba r) {
    return ( (r.x + r.size/2) > this.x) & (r.x - r.size/2) < (this.x + this.w) &
           ( (r.y + r.size/2) > this.y) & (r.y - r.size/2) < (this.y + this.h);
  }
  
  public void draw() {
     rect(x, y, w, h); 
  }
}
