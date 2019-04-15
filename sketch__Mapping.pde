// https://rosettacode.org/wiki/Map_range

float map_to(float s, int a1, int a2, int b1, int b2) {
  return b1 + (((s-a1)*(b2-b1))/(a2-a1));
}

int map_to(int s, int a1, int a2, int b1, int b2) {
  return b1 + (((s-a1)*(b2-b1))/(a2-a1));
}
