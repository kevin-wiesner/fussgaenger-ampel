PROGRAM main
  VAR
    Schritt : INT;
    Taster_FG : BOOL;
    Auto_Rot : BOOL;
    Auto_Gelb : BOOL;
    Auto_Gruen : BOOL;
    FG_Rot : BOOL;
    FG_Gruen : BOOL;
    T_Zeit : TIME;
    T1 : TON;
    Schritt_alt : INT;
  END_VAR

(* Kreuzung: Auto/Fußgaenger, nie beide gruen *)

(* 1) Grundstellung: alles Rot. Danach pro Phase Abweichung setzten *)
Auto_Rot := TRUE; Auto_Gelb := FALSE; Auto_Gruen := FALSE;
FG_Rot := TRUE; FG_Gruen := FALSE;

(* 2) Phasenfolge *)
CASE Schritt OF
    0: (* Rot-Gelb *)
    Auto_Gelb := TRUE;
    T_Zeit := T#2s;
    IF T1.Q THEN Schritt := 1; END_IF;

    1: (* Gruen + Taster funktion *)
    Auto_Rot := FALSE; Auto_Gruen := TRUE;
    IF Taster_FG THEN Schritt := 2; END_IF;

    2: (* Auto_Gelb *)
    Auto_Rot := FALSE; Auto_Gelb := TRUE;
    T_Zeit := T#3s;
    IF T1.Q THEN Schritt := 3; END_IF;

    3: (* Sicherheitszustand *)
    Auto_Gelb := FALSE; Auto_Rot := TRUE;
    T_Zeit := T#1s;
    IF T1.Q THEN Schritt := 4; END_IF;

    4: (* Fußgaenger gruen *)
    FG_Gruen := TRUE; FG_Rot := FALSE;
    T_Zeit := T#6s;
    IF T1.Q THEN Schritt := 5; END_IF;

    5: (* Sicherheitszustand *)
    FG_Gruen := FALSE; FG_Rot := TRUE;
    T_Zeit := T#1s;
    IF T1.Q THEN Schritt := 0; END_IF;

END_CASE;

(* 3) Sicherheitsverrieglung: falls beide gruen waeren, sofort abschalten *)
IF Auto_Gruen AND FG_Gruen THEN
    Auto_Gruen := FALSE;
    FG_Gruen := FALSE;
END_IF;

(* 4) Timer mit Selbstreset *)
T1(IN := (Schritt = Schritt_alt), PT := T_Zeit);
Schritt_alt := Schritt;

END_PROGRAM