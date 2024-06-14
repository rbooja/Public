
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double linear_regression_line(double &src[], int p, int i) {

  double Ey = 0;
  double Exy = 0;
  double c;

  for (int x = 0; x <= p - 1; x++) {

    c = src[x + i];
    Ey += c;
    Exy += x * c;

  }

  double Ex   = p * (p - 1) * 0.5;
  double Ex2  = (p - 1) * p * (2 * p - 1) / 6;
  double Sum2 = Ex * Ey;
  double q1 = p * Exy - Sum2;
  double q2 = Ex * Ex - p * Ex2;

  double slope = q2 != 0 ? q1 / q2 : 0;

  double intercept = (Ey - slope * Ex) / p;
  double linregval = intercept + slope * (p - 1);

  return (linregval);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double r2_calc_level(double per) {

   double per1, lev1, lenper, levdif;

   if (120 < per) return (0.03);
   else if (60 < per) { per1 = 60; lev1 = 0.06; lenper = 60; levdif = 0.03; }
   else if (50 < per) { per1 = 50; lev1 = 0.08; lenper = 10; levdif = 0.02; }
   else if (30 < per) { per1 = 30; lev1 = 0.13; lenper = 20; levdif = 0.05; }
   else if (25 < per) { per1 = 25; lev1 = 0.16; lenper =  5; levdif = 0.03; }
   else if (20 < per) { per1 = 20; lev1 = 0.20; lenper =  5; levdif = 0.04; }
   else if (14 < per) { per1 = 14; lev1 = 0.27; lenper =  6; levdif = 0.07; }
   else if (10 < per) { per1 = 10; lev1 = 0.40; lenper =  4; levdif = 0.13; }
   else if ( 5 < per) { per1 =  5; lev1 = 0.77; lenper =  5; levdif = 0.37; }
   else return (0.77);

   double result = lev1 - (per - per1) * (levdif / lenper);

   return (result);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
