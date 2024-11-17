--Este escenario comprueba solamente el Pitch, poniendo valores muy radicales tanto por arriba como por abajo.--

with Ada.Real_Time; use Ada.Real_Time;
with devicesfss_v1; use devicesfss_v1;

package Scenario_V2 is

    ---------------------------------------------------------------------
    ------ Access time for devices (igual que en Scenario_V1)
    ---------------------------------------------------------------------
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

    ---------------------------------------------------------------------
    ------ SCENARIO -----------------------------------------------------
    ---------------------------------------------------------------------

    -- Pitch con valores fuera de rango para la prueba
    cantidad_datos_Pitch: constant := 200;
    type Indice_Secuencia_Pitch is mod cantidad_datos_Pitch;
    type tipo_Secuencia_Pitch is array (Indice_Secuencia_Pitch) of Pitch_Samples_Type;

    Pitch_Simulation: tipo_Secuencia_Pitch :=  -- 1 muestra cada 100ms.
                 ( 35,35,35,35,35, 35,35,35,35,35,   -- 1s. !!! pitch > 30
                   40,40,40,40,40, 40,40,40,40,40,   -- 2s. !!! pitch = 40
                   25,25,25,25,25, 25,25,25,25,25,   -- 3s.
                   -35,-35,-35,-35,-35, -35,-35,-35,-35,-35, -- 4s. !!! pitch < -30
                   -40,-40,-40,-40,-40, -40,-40,-40,-40,-40, -- 5s. !!! pitch = -40
                   10,10,10,10,10, 10,10,10,10,10,   -- 6s.
                   50,50,50,50,50, 50,50,50,50,50,   -- 7s. !!! pitch extremo > 45
                   0,0,0,0,0, 0,0,0,0,0,             -- 8s. pitch neutral
                   -50,-50,-50,-50,-50, -50,-50,-50,-50,-50, -- 9s. !!! pitch extremo < -45
                   20,20,20,20,20, 20,20,20,20,20,   -- 10s.
                   30,30,30,30,30, 30,30,30,30,30,   -- 11s.
                   35,35,35,35,35, 35,35,35,35,35,   -- 12s. !!! pitch > 30
                   -35,-35,-35,-35,-35, -35,-35,-35,-35,-35, -- 13s. !!! pitch < -30
                   -40,-40,-40,-40,-40, -40,-40,-40,-40,-40, -- 14s. !!! pitch = -40
                   10,10,10,10,10, 10,10,10,10,10,   -- 15s.
                   0,0,0,0,0, 0,0,0,0,0,             -- 16s. pitch neutral
                   25,25,25,25,25, 25,25,25,25,25,   -- 17s.
                   40,40,40,40,40, 40,40,40,40,40,   -- 18s. !!! pitch = 40
                   -40,-40,-40,-40,-40, -40,-40,-40,-40,-40, -- 19s. !!! pitch = -40
                   30,30,30,30,30, 30,30,30,30,30);  -- 20s.

    -- Luz (sin cambios respecto al original)
    cantidad_datos_Light: constant := 200;
    type Indice_Secuencia_Light is mod cantidad_datos_Light;
    type tipo_Secuencia_Light is array (Indice_Secuencia_Light) of Light_Samples_Type;

    Light_Intensity_Simulation: tipo_Secuencia_Light :=
                 ( 700,700,700,700,700, 700,700,700,700,700,   -- 1s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 2s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 3s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 4s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 5s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 6s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 7s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 8s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 9s.
                   700,700,700,700,700, 700,700,700,700,700);  -- 10s.

    -- Potencia del piloto (sin cambios respecto al original)
    cantidad_datos_Power: constant := 200;
    type Indice_Secuencia_Power is mod cantidad_datos_Power;
    type tipo_Secuencia_Power is array (Indice_Secuencia_Power) of Power_Samples_Type;

    Power_Simulation: tipo_Secuencia_Power :=
                 ( 800,800,800,800,800, 800,800,800,800,800,   -- 1s.
                   800,800,800,800,800, 800,800,800,800,800,   -- 2s.
                   800,800,800,800,800, 700,700,700,700,700,   -- 3s.
                   900,900,900,900,900, 1000,1000,1000,1000,1000); -- 10s.

    -- Distancia (sin cambios respecto al original)
    cantidad_datos_Distancia: constant := 200;
    type Indice_Secuencia_Distancia is mod cantidad_datos_Distancia;
    type tipo_Secuencia_Distancia is array (Indice_Secuencia_Distancia) of Distance_Samples_Type;

    Distance_Simulation: tipo_Secuencia_Distancia :=
                 ( 5555,5555,5555,5555,5555, 4440,4440,4440,4440,4440, -- 10s.
                   3000,3000,3000,3000,3000, 2400,2400,2400,2400,2400); -- 20s.

    -- Joystick (sin cambios respecto al original)
    cantidad_datos_Joystick: constant := 200;
    type Indice_Secuencia_Joystick is mod cantidad_datos_Joystick;
    type tipo_Secuencia_Joystick is array (Indice_Secuencia_Joystick) of Joystick_Samples_Type;

    Joystick_Simulation: tipo_Secuencia_Joystick :=
                 ((+81,+03),(+81,+03),(+82,+01),(+83,+00),(+81,-03), (+01,+03));

end Scenario_V2;
