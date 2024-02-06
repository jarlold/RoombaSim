 ArrayList<Wall> get_empty_room() {
   // Our apartement comes unfurnished, just like in real life.
   // clearly the depth of this simulation is insane.
   ArrayList<Wall> w = new ArrayList<Wall>();   
   
   // Just the borders
   w.add(new Wall(-10, -10, 10, 800 + 10));
   w.add(new Wall(-10, -10, 600 + 10, 10));
   w.add(new Wall(800, - 10, 10, 600 + 10));
   w.add(new Wall(0, 600 , 800 + 10, 10));
   return w;
}

ArrayList<Wall> get_first_room() {
  ArrayList<Wall> room1 = get_empty_room();
  
    // Add some furniture to our simulation
  room1.add(new Wall(0, 200, 200, 200));
  room1.add(new Wall(200, 200, 200, 30));
  room1.add(new Wall(600, 200, 200, 30));
  room1.add(new Wall(0, 200+270, 50, 50));
  room1.add(new Wall(150, 200+270, 50, 50));
  room1.add(new Wall(150, 0, 50, 130));
  room1.add(new Wall(450, 350, 50, 230));
  
  return room1;
}

ArrayList<Wall> get_second_room() {
  ArrayList<Wall> room2 = get_empty_room();
  room2.add(new Wall(0, 0, 100, 100));
  return room2;
}

// Just a big list of lists of walls.
ArrayList<ArrayList<Wall>> get_rooms() {
  ArrayList<ArrayList<Wall>> rooms = new ArrayList();

  // Add the first room
  rooms.add(get_first_room());     
  rooms.add(get_second_room());


  return rooms;
}
