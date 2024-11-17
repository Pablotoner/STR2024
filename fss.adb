
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

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
        procedure getObstacle(D: out Distance_Samples_Type);
        function getPresencia return PilotPresence_Samples_Type;
        function getContador return Integer;
        procedure setContador (C : Integer);
    private
        power : Power_Samples_Type; --cambiado a no usar variables privadas, está bien???
        speed : Speed_Samples_Type;
        pitch : Pitch_Samples_Type;
        roll : Roll_Samples_Type;
        joystick : Joystick_Samples_Type;
        contador : integer := -1;
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

        procedure getObstacle(D: out Distance_Samples_Type) is
        begin
            Read_Distance(D);
        end getObstacle;

        function getPresencia return PilotPresence_Samples_Type is
        begin
            return Read_PilotPresence;
        end getPresencia;

        function getContador return integer is
        begin
            return contador;
        end getContador;

        procedure setContador (C : Integer) is
        begin
            contador := C;
        end setContador;
        
    end valores;
    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------
--Periodo mas pequeño -> prioridad mas alta, cambiarlas por variables
    -- Aqui se declaran las tareas que forman el STR

    priAltCabAla : constant Integer := 4;
    priColision : constant Integer := 3;
    priVelocidad : constant Integer := 2;
    priDisplay : constant Integer := 1;
    task controlVelocidad is pragma priority(priVelocidad); --300
    end controlVelocidad;
    task controlAltCabAla is pragma priority(priAltCabAla); --200
    end controlAltCabAla;
    task controlColision is pragma priority(priColision); --250
    end controlColision;
    task display is pragma priority(priDisplay); --1000
    end display;

    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------
    -- Aqui se escriben los cuerpos de las tareas 
    task body controlVelocidad  is
        currentPowerSetting : Power_Samples_Type;
        targetSpeed : Speed_Samples_Type;
        currentSpeed : Speed_Samples_Type;
        currentPitch : Pitch_Samples_Type;
        currentRoll : Roll_Samples_Type;
        currentJoystick : Joystick_Samples_Type;
        Next_Start : Ada.Real_Time.Time := Clock;
        periodo : constant Time_Span :=  Milliseconds(300);
    begin
        loop
            Start_Activity("Tarea Velocidad");
            Read_Power(currentPowerSetting); --valor potenciometro
            targetSpeed := Speed_Samples_Type(float(currentPowerSetting) * 1.2); --velocidad objetivo
            currentPitch := valores.getPitch; --CAMBIAR por acceso directo?
            currentRoll := valores.getRoll;
            currentSpeed := valores.getSpeed;
            valores.getJoystick(currentJoystick);

            --el rincon del debug
            --Display_Message("Velocidad actual leida: ");
            --Display_Speed(currentSpeed);
            --Display_Message("Power setting del piloto: ");
            --Display_Pilot_Power(currentPowerSetting);
            --Display_Message("Velocidad objetivo calculada: ");
            --Display_Speed(targetSpeed);
            --Display_Message("Pitch actual");
            --Display_Pitch(currentPitch);
            
            if currentSpeed > 300 and currentSpeed < 1000 then
                Light_2(Off); --si vel correcta, apaga luz
            elsif currentSpeed > 1000 then
                Light_2(On);
            elsif currentSpeed < 300 then
                --Display_Message("Velocidad inferior a 300");
                Light_2(On);
            end if;
            if targetSpeed < 1000 then
                --Display_Message("Velocidad < 1000");
                if currentPitch > 3 then
                    targetSpeed := targetSpeed + 150;
                    --Display_Message("Y pitch positivo, acelerar 150");
                end if;
                
                if currentRoll > 3 then
                    targetSpeed := targetSpeed + 100;
                    --Display_Message("Y roll, acelerar 100");
                end if;
            end if;
            if targetSpeed < 300 then
                --Display_Message("Velocidad objetivo menos de 300, limitando a 300");
                targetSpeed := 300;
            elsif targetSpeed > 1000 then
                --Display_Message("Velocidad excesiva, limitando a 1000");
                targetSpeed := 1000;
            end if;
            --posible fallo al convertir entre power setting y velocidad?
            valores.setSpeed(targetSpeed); --no asignar valor a targetSpeed hasta no haber tomado una decision??
            --Display_Message("Velocidad objetivo decidido");
            --Display_Speed(targetSpeed);
            Finish_Activity("Tarea Velocidad");
            New_Line;
            Next_Start := Next_Start + periodo;
            delay until Next_Start;
        end loop;
    end controlVelocidad;

    task body controlAltCabAla is
        currentAltitude : Altitude_Samples_Type;
        currentJoystick : Joystick_Samples_Type;
        currentRoll : Roll_Samples_Type;
        targetPitch : Pitch_Samples_Type;
        targetRoll : Roll_Samples_Type;
        Next_Start : Ada.Real_Time.Time := Clock;
        periodo : constant Time_Span :=  Milliseconds(200);
    begin
        loop
            Start_Activity("Tarea Altitud+Posicion");
            if valores.getContador = -1 then
                valores.getJoystick(currentJoystick);
                currentAltitude := valores.getAltitude;
                targetPitch := Pitch_Samples_Type(currentJoystick(x));
                --Display_Joystick(currentJoystick);
                --Display_Altitude(currentAltitude);
                if currentAltitude < 2500 then
                    --Display_Message("Altitud < 2500");
                    Light_1(On);
                    if currentAltitude < 2000 and targetPitch < 0 then
                        targetPitch := 0;
                        --Display_Message("Y < 2000 y pitch negativo, ignorando");
                    end if;
                elsif currentAltitude > 9500 then
                    Light_1(On);
                    --Display_Message("Alt > 9500");
                    if currentAltitude > 10000 and targetPitch > 0 then
                        targetPitch := 0;
                        --Display_Message("Y > 10000 y pitch pos, ignorando");
                    end if;
                else
                    Light_1(Off);
                end if;

                if targetPitch > 30 then
                    targetPitch := 30;
                    --Display_Message("pitch > 30, limitando");
                elsif targetPitch < -30 then
                    targetPitch := -30;
                    --Display_Message("pitch < -30, limitando");
                elsif targetPitch > -3 and targetPitch < 3 then
                    targetPitch := 0;
                    --Display_Message("Pitch en zona muerta");
                end if;
                --Display_Message("Pitch decidido");
                valores.setPitch(targetPitch);
                --Display_Pitch(targetPitch);

                
                targetRoll := Roll_Samples_Type(currentJoystick(y));

                
                if targetRoll > 45 then --"No se transferirán a la aeronave" limitar o 0???
                    targetRoll := 45;
                elsif targetRoll < -45 then
                    targetRoll := -45;
                end if;
                if targetRoll < 3 and targetRoll > -3 then
                        targetRoll := 0;
                end if;

                valores.setRoll(targetRoll);
                --Display_Message("Roll decidido");
                --Display_Roll(targetRoll);
            end if;
            Finish_Activity("Tarea Altitud+Posicion");
            New_Line;
            Next_Start := Next_Start + periodo;
            delay until Next_Start;
        end loop;
    end controlAltCabAla;

    --Vvertical = Va * sen(pitch)
    task body controlColision is
        obstacleDistance : Distance_Samples_Type;
        velocidadVertical : float;
        colisionTime : float := 0.0;
        Next_Start : Ada.Real_Time.Time := Clock;
        periodo : constant Time_Span :=  Milliseconds(250);
        currentSpeed : Speed_Samples_Type;
        currentPitch : Pitch_Samples_Type;
    begin
        loop
            Start_Activity("Tarea Colision");
            New_Line;
            if valores.getContador > 0 then
                Display_Message("Desvio auto. en curso: ");
                Print_an_Integer(valores.getContador);
                valores.setContador(valores.getContador -1);
            elsif valores.getContador = 0 then 
                valores.setPitch(0);
                valores.setRoll(0);
                Display_Message("Desvio auto. finalizado");
                valores.setContador(-1);
            else
                currentSpeed := valores.getSpeed;
                currentPitch := valores.getPitch;
                currentLight := Light_Samples_Type;
                Read_Light_Intensity(currentLight);
                valores.getObstacle(obstacleDistance); --o usar la del devices direct?
                --Display_Message("temita velocidad?");
                --Display_Speed(currentSpeed);
                --Display_Pitch(currentPitch);
                velocidadVertical := float(currentSpeed) * Sin(float(currentPitch), 360.0);
                --Display_Message("Vel. vertical calculada:");
                --Print_a_Float(velocidadVertical);
                colisionTime := float(obstacleDistance) / velocidadVertical;
                --Display_Message("Tiempo para colision:");
                --Print_A_Float(colisionTime);
                if colisionTime < 10.0 then
                    Alarm(4);
                    if colisionTime < 5.0 then
                        --desvio automatico
                        Display_Message("Desivio automatico");
                        if valores.getAltitude <= 8500 then
                            valores.setPitch(20);
                        elsif valores.getAltitude >= 8500 then
                            valores.setRoll(45);
                        end if;
                        valores.setContador(12);
                    end if;
                end if;

                if currentLight < 500 or valores.getPresencia = 0 then
                    if colisionTime < 15.0 then
                        Alarm(4);
                        if colisionTime < 10.0 then
                            --desvio automatico
                            Display_Message("Desvio automatico");
                            if valores.getAltitude <= 8500 then
                                valores.setPitch(20);
                            elsif valores.getAltitude >= 8500 then
                                valores.setRoll(45);
                            end if;
                            valores.setContador(12);
                        end if;
                    end if;
                end if;
            end if; --de comprobacion de contador
            Finish_Activity("Tarea Colision");
            New_Line;
            Next_Start := Next_Start + periodo;
            delay until Next_Start;
        end loop;

    end controlColision;

    task body display is
        currentAltitude : Altitude_Samples_Type;
        currentPower : Power_Samples_Type;
        currentSpeed : Speed_Samples_Type;
        currentJoystick : Joystick_Samples_Type;
        currentRoll : Roll_Samples_Type;
        currentPitch : Pitch_Samples_Type;
        Next_Start : Ada.Real_Time.Time := Clock;
        periodo : constant Time_Span :=  Milliseconds(1000);
    begin
        loop
            Start_Activity("Tarea Display");
            currentAltitude := valores.getAltitude;
            valores.getPowerSetting(currentPower);
            currentSpeed := valores.getSpeed;
            valores.getJoystick(currentJoystick);
            currentRoll := valores.getRoll;
            currentPitch := valores.getPitch;
            
            Display_Message("Altitud actual: ");
            Display_Altitude(currentAltitude);
            
            Display_Message("Potencia de los motores: ");
            Display_Pilot_Power(currentPower);
            
            Display_Message("Velocidad transferida de los motores (Km/h): ");
            Display_Speed(currentSpeed);
            
            Display_Message("Posicion del joystick: ");
            Display_Joystick(currentJoystick);

            Display_Message("Cabeceo y alabeo:");
            Display_Pitch(currentPitch);
            Display_Roll(currentRoll);
            if currentRoll > 35 or currentRoll < -35 then
                Display_Message("Alabeo excesivo!");
            end if;
            
            
            Finish_Activity("Tarea Display");
            New_Line;
            Next_Start := Next_Start + periodo;
            delay until Next_Start;
        end loop;
    end display;
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



