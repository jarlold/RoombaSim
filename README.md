# Roomba Sim
Genetic algorithm to train a small vacuum cleaner to clean up after me.

# What
Genetically evolving Roombas in order to get them to clean my room.

# How
I wrote a basic implementation of a densely connected feed-forward neural
network, with some common activation functions I found on Wikipedia. Then I
wrote a genetic algorithm as per !(this book)[].

## Some Details
- I tried both Gaussian selection and Gaussian mutation, and both performed
  worse than direct selection and continuously distributed selection. My guess 
  is those methods work better on more complex problems.

- The neural networks are small enough that the overhead of implementing them
  with a node-system wouldn't be worth the performance benefit of being able to
  more easily vary their size. So instead each neural network is (relatively)
  oversized for the problem, and if a Roomba does not need the extra links, he
  can just assign their weights to 0 or 1.

- I have Roomba breeding code, but it was written in C++ and I need to port this
  to that or that to this, it's on it's way I pinky promise!

# Why?
~~Seemed easier than buying a broom.~~ I just wanted to implement genetic
algorithms for something useful. And while this is a bit of a silly project, the
core concepts are reusable and even the idea behind it is doable. Of course most
companies don't care, but if you were a real penny pincher you could use
something like this to minimize the number of sensors (and thus components)
needed on a Roomba, and reduce its overall cost, and environmental impact.
