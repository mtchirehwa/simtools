// Purpose: Simulation of PK and target in plasma concentrations QE approximation
// Date: 22-June-2022
// Author: Maxwell T. Chirehwa


$PARAM @annotated  // Fixed effects
TVCL     :  0.0781  : Clearance (L/day)
TVV1     :  2.130   : Central Volume (L)
TVQ1     :  0.371   : Inter-compartmental clearance (L/day)
TVV2     :  2.137   : Peripheral volume of distribution (volume)
TVKA     :  0.282   : Absorption rate constant (1/d)
TVF1     :  0.744   : Bioavailability fraction (.) // Non-transformed [between 0 and 1]
TVKD     :  0.2115  : Equilibrium dossiciation constant (nM)
TVKINT   :  0.2415  : Internalization rate constant (1/day)
TVKDEG   :  40.8    : Degradation rate (1/day)
TVBASE   :  0.0000326 : Baseline target  (nM)
TVWT     :  70      : Average weight (kg)
WT       :  70      : Individual weight (kg)
WTCL     :  0.75    : Exponent WT on clearances
WTV      :  1       : Exponent WT on Volumes
MW_mAb   : 150      : Molecular weight of the compound [kDa]
MW_TARGT : 14       : Molecular weight of the target [kDa]

// Define omegas, variance scale
$OMEGA @annotated
ECL:   0      : Eta on CL
EV1:   0      : Eta on V1
EQ1:   0      : Eta on Q
EV2:   0      : Eta on V2
EKA:   0      : Eta on KA
EF1:   0      : Eta on F1
EKD:   0      : Eta on KD
EKINT: 0      : Eta on KINT
EKDEG: 0      : Eta on KDEG
EBASE: 0      : Eta on BASE

// Define compartments
$CMT @annotated
GUT    : Dosing compartment (mg)
CENT   : Central compartment (nM)
PER1   : Peripheral compartment 1 (nM)
TARGT  : Total target (nM)
cAUC    : AUC compartment for total mAb [nM*day/L]
cAUCFreeng : AUC for Free mAb in [ng*day/mL]
cAUCTotalng : AUC for Total mAb in [ng*day/mL]

$GLOBAL  // Global parameter definitions
#define CTOTnM  (CENT/V1) // Total drug concentration [nM/L]
#define RTOTnM (TARGT) // Total target [nM]
#define CFREEnM  (0.5*((CTOTnM - RTOTnM - KD) + sqrt(pow((CTOTnM - RTOTnM - KD),2) + 4*KD*CTOTnM))) // Free drug [nM/L]
#define COMPLXnM   (RTOTnM*CFREEnM/(KD + CFREEnM)) // Total target-drug complex concentration [nM/L]
#define FREETARGTnM  (RTOTnM*KD/(KD + CFREEnM)) // Free (unbound) target concentration  [nM/L]
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
  THETA_F1 = -1000000; // large number so that we do not attempt to find the log of 0
} else {
  THETA_F1 = log(TVF1/(1-TVF1));
}

double F1    = 1/(1 + exp(-(THETA_F1 + EF1)));  // Transform TVF1 to (-inf, +inf), add variability, then transform back to [0,1]

// TE parameters
double KD   = TVKD*exp(EKD);
double KINT = TVKINT*exp(EKINT);
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
dxdt_GUT       = -KA*GUT;  // Depot drug amount [mg]
dxdt_CENT      = KA*GUT*mAb_mg_nM - (KEL + KPT)*CFREEnM*V1 + KTP*PER1 - KINT*RTOTnM*CFREEnM*V1/(KD + CFREEnM); // Total drug amount [nM]
dxdt_PER1      = KPT*CFREEnM*V1 -  KTP*PER1; // Unbound drug amount [nM]
dxdt_TARGT     = KSYN - KDEG*TARGT - (KINT - KDEG)*TARGT*CFREEnM/(KD + CFREEnM); // Total target concentration [nM]
dxdt_cAUC       = CENT/V1;  // AUC of total mAb [nM*day/L]
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
KD   : Equilibrium dossiciation constant (nM)
KINT : Internalization rate constant (/day)
KDEG : Degradation rate (/day)
BASE : Baseline target  (nMol)


