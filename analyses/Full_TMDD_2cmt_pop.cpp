// Purpose: Simulation of PK and target in plasma concentrations Full TMDD
// Date: 27-June-2022
// Author: Maxwell T. Chirehwa


$PARAM @annotated
TVCL     :  1.38  : Clearance (volume/time)
TVV1     :  8.58 : Central volume (volume)
TVQ1     :  0.374  : Inter-compartmental clearance (volume/time)
TVV2     :  5.69  : Peripheral volume of distribution (volume)
TVKA     :  0.644  : Absorption rate constant (1/time)
TVF1     :  0.216   : Bioavailability fraction (.)
TVWT     :  70      : Average weight (kg)
WT       :  70      : Individual weight
WTCL     :  0.75   : Exponent WT on CL
WTV      :  1   : Exponent WT on V
TVKOFF   :  0.38  : Dissociation constant (/day)
TVKINT   :  0.0683   : Internalization rate constant (/day)
TVKON    :  24.8   : Association constant 2nd order (/nM/day))
TVKDEG   :  40.6   : Degradation rate (/day)
TVBASE   :  0.0000451 : Baseline target  (nMol)
MW_mAb   : 150      : Molecular weight of the compound [kDa]
MW_TARGT : 14       : Molecular weight of the target [kDa]

$OMEGA  @annotated
ECL:   0      : Eta on CL
EV1:   0      : Eta on V1
EKA:   0      : Eta on KA
EF1:   0      : Eta on F1
EV2:   0      : Eta on V2
EQ1:   0      : Eta on Q
EBASE: 0      : Eta on BASE
EKON:  0      : Eta on Kon
EKDEG: 0      : Eta on KDEG
EKINT: 0      : Eta on KINT
EKOFF: 0      : Eta on KOFF

// Define compartments
$CMT @annotated
GUT    : Dosing compartment [mg]
CENT   : Central compartment [nM]
PER1   : Peripheral compartment 1 [nM]
COMPLX : Complex conc in central
TARGT  : Total target [nM]
cAUC    : AUC compartment for Free mAb [nM*day/L]
cAUCFreeng : AUC for Free mAb in [ng*day/mL]
cAUCTotalng : AUC for Total mAb in [ng*day/mL]


$GLOBAL  // Global parameter definitions
#define SCL_mAb (1/MW_mAb) // Scaling mAb
#define SCL_TARGT (1/(1000*MW_TARGT)) // Scaling target
#define CFREEnM (CENT/V1)  // // Free mAb concentration [nM/L]
#define COMPLXnM (COMPLX) // Total target-drug complex concentration [nM/L]
#define FREETARGTnM (TARGT) // Free (unbound) target concentration  [nM/L]
#define CTOTnM (CFREEnM + COMPLXnM) // Total drug concentration [nM/L]
#define RTOTnM (FREETARGTnM + COMPLXnM) // Total target [nM]
#define TargetEng   (100*(1 - FREETARGTnM/BASE)) // Target engagement [%]
#define CTOTngmL  (CTOTnM*MW_mAb)    // Total drug concentration [ng/mL]
#define CFREEngmL (CFREEnM*MW_mAb)    // Free drug concentration [ng/mL]
#define FREETARGTpgmL (FREETARGTnM*MW_TARGT*1000) // Free (unbound) target concentration  [pg/mL]
#define COMPLXpgmL  (COMPLXnM*MW_TARGT*1000) // Total target-drug complex concentration [pg/mL]

$MAIN // Define parameters
// PK parameters
double CL   = TVCL*pow(WT/TVWT, WTCL)*exp(ECL);
double V1   = TVV1*pow(WT/TVWT, WTV)*exp(EV1);
double Q1   = TVQ1*pow(WT/TVWT, WTCL)*exp(EQ1);
double V2   = TVV2*pow(WT/TVWT, WTV)*exp(EV2);
double KA   = TVKA*exp(EKA);

// Bioavailability
if (TVF1 == 1){
  double THETA_F1 = 1000000;  // large number so that we do not divide by zero in logit transform
} else if (TVF1 == 0) {
  THETA_F1 = -1000000;
} else {
  THETA_F1 = log(TVF1/(1-TVF1));
}

double F1    = 1/(1 + exp(-(THETA_F1 + EF1)));  // Transform TVF1 to (-inf, +inf), add variability, then transform back to [0,1]

// TE parameters
double KINT = TVKINT*exp(EKINT);
double KON  = TVKON*exp(EKON);
double KOFF = TVKOFF*exp(EKOFF);
double KDEG = TVKDEG*exp(EKDEG);
double BASE = TVBASE*exp(EBASE);

// Initialize compartment
TARGT_0 = BASE;

// Assign bioavailability
F_GUT   = F1;

// Define secondary parameters
double KSYN = BASE*KDEG;  // GM-CSF synthesis rate
double KEL  = CL/V1;  // Drug elimination rate constant
double KPT  = Q1/V1;  // Transfer rate constant of drug from central to tissue
double KTP  = Q1/V2;  // Transfer rate constant of drug from tissue to central
double mAb_mg_nM = 1000/MW_mAb; // To convert mg to nM for compound

$ODE
dxdt_GUT       = -KA*GUT; // Depot drug amount [mg]
dxdt_CENT      = KA*GUT*mAb_mg_nM - KEL*CENT - KPT*CENT + KTP*PER1 -  KON*CENT*TARGT + KOFF*COMPLX; // Free drug amount [nM]
dxdt_PER1      = KPT*CENT -  KTP*PER1; // Unbound drug amount [nM]
dxdt_TARGT     = KSYN - KDEG*TARGT - KON*CFREEnM*TARGT + KOFF*COMPLX ; // // Total target concentration [nM]
dxdt_COMPLX    = KON*CFREEnM*TARGT - (KOFF+KINT)*COMPLX; // Total target-drug complex concentration [nM]
dxdt_cAUC       = CFREEnM; // AUC of Free mAb [nM*day/L]
dxdt_cAUCFreeng = CFREEngmL; // AUC of FREE mAb [ng*day/mL]
dxdt_cAUCTotalng= CTOTngmL; // AUC of Total mAb [ng*day/mL]

$CAPTURE @annotated
FREETARGTnM : Free target  [nM]
TargetEng  : Target engagement [%]
CFREEnM   : Free mAb [nM]
COMPLXnM  : Complex [nM]
CTOTnM    : Total mAb [nM]
CTOTngmL : Complex [ng/mL]
FREETARGTpgmL : Free target  [pg/mL]
COMPLXpgmL : Complex [pg/mL]
CFREEngmL : Free mAb [ng/mL]
// Parameters [can be excluded from the simulation output via update(mod, "XXX")]
CL : Clearance (volume/time)
V1 : Central volume (volume)
Q1 : Inter-compartmental clearance (volume/time)
V2 : Peripheral volume of distribution (volume)
KA : Absorption rate constant (1/time)
F1 : Bioavailability fraction (.)
WT   : Individual weight
WTCL : Exponent WT on CL
WTV  : Exponent WT on V
KOFF : Dissociation constant (/day)
KINT : Internalization rate constant (/day)
KON  : Association constant 2nd order (/nM/day))
KDEG : Degradation rate (/day)
BASE : Baseline target  (nMol)
