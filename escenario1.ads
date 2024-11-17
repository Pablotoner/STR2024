--Límite del Pitch: Verificar si el sistema limita correctamente los valores del pitch a ±30 grados.--
--Distancia: Evaluar si se activan alarmas o desviaciones automáticas cuando la distancia es crítica.--
--Presencia del Piloto: Comprobar que el sistema activa protocolos de emergencia cuando el piloto no está presente.--


with Ada.Real_Time; use Ada.Real_Time;
with devicesfss_v1; use devicesfss_v1;

package Scenario_V4 is

    WCET_Distance: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Light: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Joystick: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_PilotPresence: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_PilotButton: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Power: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    WCET_Speed: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(7);
    WCET_Altitude: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);
    WCET_Pitch: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(20);
    WCET_Roll: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);
    WCET_Display: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(15);
    WCET_Alarm: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);

    cantidad_datos_Pitch: constant := 200;
    type Indice_Secuencia_Pitch is mod cantidad_datos_Pitch;
    type tipo_Secuencia_Pitch is array (Indice_Secuencia_Pitch) of Pitch_Samples_Type;

    Pitch_Simulation: tipo_Secuencia_Pitch :=
                 ( 10,15,20,25,30, 35,40,45,50,55,
                   55,50,45,40,35, 30,25,20,15,10,
                   -10,-15,-20,-25,-30, -35,-40,-45,-50,-55);

    cantidad_datos_Light: constant := 200;
    type Indice_Secuencia_Light is mod cantidad_datos_Light;
    type tipo_Secuencia_Light is array (Indice_Secuencia_Light) of Light_Samples_Type;

    Light_Intensity_Simulation: tipo_Secuencia_Light :=
                 ( 0,100,200,300,400, 500,600,700,800,900,
                   1000,900,800,700,600, 500,400,300,200,100);

    cantidad_datos_Power: constant := 200;
    type Indice_Secuencia_Power is mod cantidad_datos_Power;
    type tipo_Secuencia_Power is array (Indice_Secuencia_Power) of Power_Samples_Type;

    Power_Simulation: tipo_Secuencia_Power :=
                 ( 500,600,700,800,900, 1000,1100,1200,1300,1400,
                   1400,1300,1200,1100,1000, 900,800,700,600,500);

    cantidad_datos_Distancia: constant := 200;
    type Indice_Secuencia_Distancia is mod cantidad_datos_Distancia;
    type tipo_Secuencia_Distancia is array (Indice_Secuencia_Distancia) of Distance_Samples_Type;

    Distance_Simulation: tipo_Secuencia_Distancia :=
                 ( 6000,5000,4000,3000,2000, 1500,1000,500,400,300,
                   300,400,500,1000,1500, 2000,3000,4000,5000,6000);

    cantidad_datos_Joystick: constant := 200;
    type Indice_Secuencia_Joystick is mod cantidad_datos_Joystick;
    type tipo_Secuencia_Joystick is array (Indice_Secuencia_Joystick) of Joystick_Samples_Type;

    Joystick_Simulation: tipo_Secuencia_Joystick :=
                 ((+10,+10),(+20,+20),(+30,+30),(+40,+40),(+50,+50),
                  (0,0),(-50,-50),(-40,-40),(-30,-30),(-20,-20),
                  (-10,-10),(0,0),(+50,-50),(-50,+50),(0,0));

    cantidad_datos_PilotPresence: constant := 200;
    type Indice_Secuencia_PilotPresence is mod cantidad_datos_PilotPresence;
    type tipo_Secuencia_PilotPresence is array (Indice_Secuencia_PilotPresence) of PilotPresence_Samples_Type;

    PilotPresence_Simulation: tipo_Secuencia_PilotPresence :=
                 ( 1,1,0,1,0, 1,1,1,0,0,
                   1,1,1,1,0, 0,0,1,1,1);

    cantidad_datos_PilotButton: constant := 200;
    type Indice_Secuencia_PilotButton is mod cantidad_datos_PilotButton;
    type tipo_Secuencia_PilotButton is array (Indice_Secuencia_PilotButton) of PilotButton_Samples_Type;

    PilotButton_Simulation: tipo_Secuencia_PilotButton :=
                 ( 0,0,1,1,0, 0,1,1,0,1,
                   0,0,1,0,1, 1,0,0,0,1);

end Scenario_V4;