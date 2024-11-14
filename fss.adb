
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;

-- NO ACTIVAR ESTE PAQUETE MIENTRAS NO SE TENGA PROGRAMADA LA INTERRUPCION
-- Packages needed to generate button interrupts       
-- with Ada.Interrupts.Names;
-- with Button_Interrupt; use Button_Interrupt;

package body fss is
    
    ----------------------------------------------------------------------
    ------------- procedure exported 
    ----------------------------------------------------------------------
    procedure Background is
    begin
      loop
        null;
      end loop;
    end Background;
    ----------------------------------------------------------------------

    -----------------------------------------------------------------------
    ------------- declaration of protected objects 
    -----------------------------------------------------------------------
    --el objeto protegido tiene que tenere la prioridad mayor de todas las tareas que lo utilizan
    -- 1 solo objeto protegido compartido entre velocidad y posicion-altitud?
    --semaforo desde que 1 toca el objeto hasta que sale?
    -- Aqui se declaran los objetos protegidos para los datos compartidos  
    protected valores is
        procedure getPowerSetting(P: out Power_Samples_Type);
        --procedure setPowerSetting(nuevoValor : Power_Samples_Type; --innecesario???
        function getSpeed return Speed_Samples_Type;
        procedure setSpeed(nuevoValor : Speed_Samples_Type);
        function getRoll return Roll_Samples_Type;
        procedure setRoll(nuevoValor : Roll_Samples_Type);
        function getPitch return Pitch_Samples_Type;
        procedure setPitch(nuevoValor : Pitch_Samples_Type);
        procedure getJoystick (J: out Joystick_Samples_Type);
        procedure setJoystick(nuevoValor : Joystick_Samples_Type);
        function getAltitude return Altitude_Samples_Type;
        function getObstacle return Distance_Samples_Type;
        function getPresencia return PilotPresence_Samples_Type;
    private
        power : Power_Samples_Type; --cambiado a no usar variables privadas, está bien???
        speed : Speed_Samples_Type;
        pitch : Pitch_Samples_Type;
        roll : Roll_Samples_Type;
        joystick : Joystick_Samples_Type;
    end valores;

    protected body valores is
        procedure getPowerSetting (P: out Power_Samples_Type) is
        begin
            Read_Power(P);
        end getPowerSetting;

        function getSpeed return Speed_Samples_Type is
        begin
            return Read_Speed;
        end getSpeed;

        procedure setSpeed(nuevoValor : Speed_Samples_Type) is
        begin
            Set_Speed(nuevoValor);
        end setSpeed;

        function getRoll return Roll_Samples_Type is
        begin
            return Read_Roll;
        end getRoll;

        procedure setRoll(nuevoValor : Roll_Samples_Type) is
        begin
            Set_Aircraft_Roll(nuevoValor);
        end setRoll;
        
        function getPitch return Pitch_Samples_Type is
        begin
            return Read_Pitch;
        end getPitch;

        procedure setPitch(nuevoValor : Pitch_Samples_Type) is
        begin
            Set_Aircraft_Pitch(nuevoValor);
        end setPitch;

        procedure getJoystick (J: out Joystick_Samples_Type) is
        begin
            Read_Joystick(J);
        end getJoystick;

        --el programa no debe hacer set del joystick al ser input del piloto,
        --setJoystick innecesario?????? los demas sets de inputs tambien??
        procedure setJoystick(nuevoValor : Joystick_Samples_Type) is
        begin
            joystick := nuevoValor;
        end setJoystick;

        function getAltitude return Altitude_Samples_Type is
        begin
            return Read_Altitude;
        end getAltitude;

        function getObstacle return Distance_Samples_Type is
        begin
            return Read_Distance;
        end getObstacle;

        function getPresencia return PilotPresence_Samples_Type is
        begin
            return Read_PilotPresence;
        end getPresencia;
        
    end valores;
    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------
--Periodo mas pequeño -> prioridad mas alta, cambiarlas por variables
    -- Aqui se declaran las tareas que forman el STR
    task controlVelocidad is pragma priority(1);
    end controlVelocidad;
    task controlAltCabAla is pragma priority(2);
    end controlAltCabAla;
    task controlColision is pragma priority(3);
    end controlColision;

    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------
    -- Aqui se escriben los cuerpos de las tareas 
    task body controlVelocidad  is
        currentPowerSetting : Power_Samples_Type;
        targetSpeed : Speed_Samples_Type; --cambiar por getters directamente?
        currentSpeed : Speed_Samples_Type;
        currentPitch : Pitch_Samples_Type;
        currentRoll : Roll_Samples_Type;
        currentJoystick : Joystick_Samples_Type;
        inicio : Ada.Real_Time.Time;
    begin
        loop
            Start_Activity("Tarea Velocidad");
            Read_Power(currentPowerSetting); --valor potenciometro
            targetSpeed := Speed_Samples_Type(float(currentPowerSetting) * 1.2); --velocidad objetivo
            currentPitch := 5; --CAMBIAR
            currentRoll := 5; --CAMBIAR
            currentSpeed := valores.getSpeed;
            valores.getJoystick(currentJoystick);
            
            Display_Message("Velocidad actual leida: ");
            Display_Speed(currentSpeed);
            
            Display_Message("Power setting del piloto: ");
            Display_Pilot_Power(currentPowerSetting);
            
            Display_Message("Velocidad objetivo calculada: ");
            Display_Speed(targetSpeed);
            
            Display_Message("Pitch actual");
            Display_Pitch(currentPitch);
            
            Display_Message("Joystick actual:");
            Display_Joystick(currentJoystick);
            
            if currentSpeed > 300 and currentSpeed < 1000 then
                Light_2(Off); --si vel correcta, apaga luz
            end if;
            if currentSpeed > 1000 then
                Light_2(On);
            end if;
            if currentSpeed < 300 then
                Display_Message("Velocidad inferior a 300");
                Light_2(On);
            end if;
            if currentSpeed < 1000 then
                Display_Message("Velocidad < 1000");
                if currentPitch > 1 then --1 como umbral, cambiar para ser +o- sensible
                    targetSpeed := targetSpeed + 150;
                    Display_Message("Y pitch positivo, acelerar 150");
                end if;
                
                if currentRoll > 1 then
                    targetSpeed := targetSpeed + 100;
                    Display_Message("Y roll, acelerar 100");
                end if;
            end if;
            if targetSpeed < 300 then
                Display_Message("Velocidad objetivo menos de 300, limitando a 300");
                targetSpeed := 300;
            end if;
            if targetSpeed > 1000 then
                Display_Message("Velocidad excesiva, limitando a 1000");
                targetSpeed := 1000;
            end if;
            --posible fallo al convertir entre power setting y velocidad
            valores.setSpeed(targetSpeed); --no asignar valor a targetSpeed hasta no haber tomado una decision??
            Display_Message("Velocidad objetivo decidido");
            Display_Speed(targetSpeed);
            Finish_Activity("Tarea Velocidad");
            New_Line;
        delay until (Clock + To_time_Span(0.3));
        end loop;
    end controlVelocidad;

    task body controlAltCabAla is
        currentAltitude : Altitude_Samples_Type;
        currentJoystick : Joystick_Samples_Type;
        currentPitch : Pitch_Samples_Type;
        currentRoll : Roll_Samples_Type;
        targetPitch : Pitch_Samples_Type;
        targetRoll : Roll_Samples_Type;
    begin
        loop
            valores.getJoystick(currentJoystick);
            currentAltitude := valores.getAltitude;
            targetPitch := currentJoystick(x);
            if currentAltitude < 2500 then
                Light_1(On);
                if currentAltitude < 2000 and targetPitch < 0 then
                    targetPitch := 0;
                end if;
            end if;

            if currentAltitude > 9500 then
                Light_1(On);
                if currentAltitude > 10000 and targetPitch > 0 then
                    targetPitch := 0;
                end if;
            end if;

            if currentPitch > 30 then
                targetPitch := 30;
            end if;

            if currentPitch < -30 then
                targetPitch := -30;
            end if;

            if currentPitch > -3 and currentPitch < 3 then
                targetPitch := 0;
            end if;

            valores.setPitch(targetPitch);

            
            targetRoll := currentJoystick(y);

            if targetRoll > 35 or targetRoll < -35 then
                Display_Message("Cabeceo excesivo!");

                if targetRoll > 45 then --"No se transferirán a la aeronave" limitar o 0???
                    targetRoll := 45;
                end if;

                if targetRoll < -45 then
                    targetRoll := -45;
                end if;
            end if;

            valores.setRoll(targetRoll);
            delay until (Clock + To_time_Span(0.2));
        end loop;
    end controlAltCabAla;

    --Vvertical = Va * sen(pitch)
    task body controlColision is
        contador : integer;
        obstacleDistance : Distance_Samples_Type;
        velocidadVertical : Speed_Samples_Type;
        colisionTime : integer := -1;
    begin
        loop
            if contador > 0 then
                contador := contador -1;
            elsif contador = 0 then 
                valores.setPitch(0);
                valores.setRoll(0);
                contador := -1;
            else
                obstacleDistance := valores.getObstacle; --o usar la del devices direct?
                velocidadVertical := valores.getSpeed * sine(valores.getPitch);
                colisionTime := velocidadVertical / obstacleDistance;

                if colisionTime < 10 then
                    Alarm(4);
                end if;

                if colisionTime < 5 then
                    --desvio automatico
                    if valores.getAltitude <= 8500 then
                        valores.setPitch(20);
                    elsif valores.getAltitude >= 8500 then
                        valores.setRoll(45);
                    end if;
                    contador := 12;
                end if;

                if obstacleDistance < 500 or valores.getPresencia = 0 then
                    if colisionTime < 15 then
                        Alarm(4);
                    elsif colisionTime < 10 then
                        --desvio automatico
                        if valores.getAltitude <= 8500 then
                            valores.setPitch(20);
                        elsif valores.getAltitude >= 8500 then
                            valores.setRoll(45);
                        end if;
                        contador := 12;
                    end if;
                end if;
            end if;
                
        delay until (Clock + To_time_Span(0.25));
        end loop;

    end controlColision;
    ----------------------------------------------------------------------
    ------------- procedimientos para probar los dispositivos 
    ------------- SE DEBERÁN QUITAR PARA EL PROYECTO
    ----------------------------------------------------------------------
    procedure Prueba_Velocidad_Distancia; 
    procedure Prueba_Altitud_Joystick; 
    procedure Prueba_Sensores_Piloto;
    
    Procedure Prueba_Velocidad_Distancia is

        Current_Pw: Power_Samples_Type := 0;
        Current_S: Speed_Samples_Type := 500; 
        Calculated_S: Speed_Samples_type := 0; 
             
        Current_D: Distance_Samples_Type := 0;
        Current_L: Light_Samples_Type := 0;
        
    begin

         for I in 1..200 loop     -- Se limita a 200 iteraciones
             Start_Activity ("Prueba_Velocidad"); 
                   
            -- Prueba potencia del piloto 
            Read_Power (Current_Pw);  -- lee la potencia de motor indicada por el piloto
            Display_Pilot_Power (Current_Pw);
                      
            -- transfiere la potencia/velocidad a la aeronave
            Calculated_S := Speed_Samples_type (float (Current_Pw) * 1.2); -- aplicar fórmula
            Set_Speed (Calculated_S);
            if (Calculated_S > 1000) then Light_1 (On);
                                     else Light_1 (Off);
            end if;
            
            -- Comprueba la velocidad real de la aeronave
            Current_S := Read_Speed;        -- lee la velocidad actual de la aeronave
            Display_Speed (Current_S);

            -- Prueba distancia con obstaculos
            Read_Distance (Current_D);
            Display_Distance (Current_D);
                                 
            Finish_Activity ("Prueba_Velocidad");
            New_Line;
         delay until (Clock + To_time_Span(0.1));
         end loop;


    end Prueba_Velocidad_Distancia;

    Procedure Prueba_Altitud_Joystick is
        
        Current_J: Joystick_Samples_Type := (0,0);
        Target_Pitch: Pitch_Samples_Type := 0;
        Target_Roll: Roll_Samples_Type := 0; 
        Aircraft_Pitch: Pitch_Samples_Type; 
        Aircraft_Roll: Roll_Samples_Type;
        
        Current_A: Altitude_Samples_Type := 8000;
        
    begin
         for I in 1..300 loop     
            Start_Activity ("Prueba_Altitud");
            
            -- Lee Joystick del piloto
            Read_Joystick (Current_J);
            
            -- establece Pitch y Roll en la aeronave
            Target_Pitch := Pitch_Samples_Type (Current_J(x));
            Target_Roll := Roll_Samples_Type (Current_J(y));
                                      
            Set_Aircraft_Pitch (Target_Pitch);  -- transfiere el movimiento pitch a la aeronave
            Set_Aircraft_Roll (Target_Roll);    -- transfiere el movimiento roll  a la aeronave 
                       
            Aircraft_Pitch := Read_Pitch;       -- lee la posición pitch de la aeronave
            Aircraft_Roll := Read_Roll;         -- lee la posición roll  de la aeronave
            
            Display_Joystick (Current_J);       -- muestra por display el joystick  
            Display_Pitch (Aircraft_Pitch);     -- muestra por display la posición de la aeronave  
            Display_Roll (Aircraft_Roll);

            -- Comprueba altitud
            Current_A := Read_Altitude;         -- lee y muestra por display la altitud de la aeronave  
            Display_Altitude (Current_A);
            
            if (Current_A > 9000) then Alarm (3); 
                                       Display_Message ("To high");
            end if; 
               
            Finish_Activity ("Prueba_Altitud");                      
         delay until (Clock + To_time_Span(0.1));
         end loop;

         Finish_Activity ("Prueba_Altitud");
    end Prueba_Altitud_Joystick;


    Procedure Prueba_Sensores_Piloto is
        Current_Pp: PilotPresence_Samples_Type := 1;
        Current_Pb: PilotButton_Samples_Type := 0;
    begin

         for I in 1..120 loop
            Start_Activity ("Prueba_Piloto");                
            -- Prueba presencia piloto
            Current_Pp := Read_PilotPresence;
            if (Current_Pp = 0) then Alarm (1); end if;   
            Display_Pilot_Presence (Current_Pp);
                 
            -- Prueba botón para selección de modo 
            Current_Pb := Read_PilotButton;            
            Display_Pilot_Button (Current_Pb); 
            
            Finish_Activity ("Prueba_Piloto");  
         delay until (Clock + To_time_Span(0.1));
         end loop;

         Finish_Activity ("Prueba_Piloto");
    end Prueba_Sensores_Piloto;


begin
   Start_Activity ("Programa Principal");
   --Prueba_Velocidad_Distancia;
   -- Prueba_Altitud_Joystick;
   -- Prueba_Sensores_Piloto;
   Finish_Activity ("Programa Principal");
end fss;



