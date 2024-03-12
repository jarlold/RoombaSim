 ArrayList<Wall> get_empty_room() {
   // Our apartement comes unfurnished, just like in real life.
   // clearly the depth of this simulation is insane.
   ArrayList<Wall> w = new ArrayList<Wall>();   
   
   // Just the borders
   w.add(new Wall(-10, -10, 10, 800*5));
   w.add(new Wall(-10, -10, 600*5, 10));
   w.add(new Wall(800, - 10, 10, 600 + 10));
   w.add(new Wall(0, 600 , 800 + 10, 10));
   return w;
}

ArrayList<Wall> get_first_room() {
  // Some other room I was using a while for development, I'm partial to it bc i see it so much
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

//Convert inches to pixels
float in_to_pix(float inches) {return ( (40/13) * inches);}

ArrayList<Wall> get_third_room() {
  // This one will be a replica of my actual apartement 
  ArrayList<Wall> room3 = get_empty_room();
  // side walls are 140 inches accross
  // The workbench
  room3.add(new Wall(
    in_to_pix(0), in_to_pix(140 -17),
    in_to_pix(2), in_to_pix(1.2)
  ));
   room3.add(new Wall(
    in_to_pix(31), in_to_pix(140 -17),
    in_to_pix(2), in_to_pix(1.2)
  ));
  room3.add(new Wall(
    in_to_pix(0), in_to_pix(140 -17 - 50),
    in_to_pix(2), in_to_pix(1.2)
  ));
   room3.add(new Wall(
    in_to_pix(31), in_to_pix(140 -17 -50),
    in_to_pix(2), in_to_pix(1.2)
  ));
  
  // Trash can thats usually in the middle of the room
  room3.add(new Wall( 400, 350, in_to_pix(12), in_to_pix(12) ));
  
  // Kitchenette
  room3.add(new Wall(width-in_to_pix(26), height - in_to_pix(12*12), in_to_pix(26), in_to_pix(12*12)));
  
  // Two chairs with a board accross them that i grow onion on
  // Roombas absolutely hate these things
  room3.add(new Wall(0, 0, in_to_pix(2), in_to_pix(2)));
  room3.add(new Wall(in_to_pix(17), 0, in_to_pix(2), in_to_pix(2)));
  room3.add(new Wall(0, in_to_pix(17), in_to_pix(2), in_to_pix(2)));
  room3.add(new Wall(in_to_pix(17), in_to_pix(17), in_to_pix(2), in_to_pix(2)));
  
  room3.add(new Wall(in_to_pix(17), 0, in_to_pix(2), in_to_pix(2)));
  room3.add(new Wall(in_to_pix(17*2), 0, in_to_pix(2), in_to_pix(2)));
  room3.add(new Wall(in_to_pix(17), in_to_pix(17), in_to_pix(2), in_to_pix(2)));
  room3.add(new Wall(in_to_pix(17*2), in_to_pix(17), in_to_pix(2), in_to_pix(2)));
  
  // Recycling bin (with bits of recyling overflowing because im a slob)
  // The trash isn't always in the same spot in real life, so here i just picked an annoying position for it.
  room3.add(new Wall(in_to_pix(17*2 + 4), 0, in_to_pix(14), in_to_pix(14)));
  room3.add(new Wall(in_to_pix(17*2 + 4 + 3), in_to_pix(14+15), in_to_pix(4), in_to_pix(3)));
  
  // Computer, monitor, and cardboard box i keep it on.
  room3.add(new Wall(in_to_pix(17*2 +4 + 14 + 2), 0, in_to_pix(7), in_to_pix(15)));
  room3.add(new Wall(in_to_pix(17*2 +4 + 14 + 2 + 7 + 5), 0, in_to_pix(20), in_to_pix(14)));
  
  return room3;
}

ArrayList<Wall> get_second_room() {
  // Roomba hell
  ArrayList<Wall> room2 = get_empty_room();

  for (int i = 0; i < 800; i += 50*2) {
    for (int j = 0; j < 600; j += 150)
      room2.add(new Wall(i, j, 50, 50));
  }

  return room2;
}

// Just a big list of lists of walls.
ArrayList<ArrayList<Wall>> get_rooms() {
  ArrayList<ArrayList<Wall>> rooms = new ArrayList();

  // Add the first room
  rooms.add(get_third_room());
  rooms.add(get_first_room());     
  rooms.add(get_second_room());

  return rooms;
}
