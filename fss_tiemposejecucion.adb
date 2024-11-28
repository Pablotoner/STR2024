
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;

package body fss is
    
    procedure Background is
    begin
      loop
        null;
      end loop;
    end Background;

    protected valores is
        procedure getPowerSetting(P: out Power_Samples_Type);
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
        power : Power_Samples_Type;
        speed : Speed_Samples_Type;
        pitch : Pitch_Samples_Type;
        roll : Roll_Samples_Type;
        joystick : Joystick_Samples_Type;
        contador : integer := -1;
    end valores;

    protected body valores is
        procedure getPowerSetting (P: out Power_Samples_Type) is
        begin
            Execution_Time(Milliseconds(2));
            Read_Power(P);
        end getPowerSetting;

        function getSpeed return Speed_Samples_Type is
        begin
            Execution_Time(Milliseconds(2));
            return Read_Speed;
        end getSpeed;

        procedure setSpeed(nuevoValor : Speed_Samples_Type) is
        begin
            Execution_Time(Milliseconds(3));
            Set_Speed(nuevoValor);
        end setSpeed;

        function getRoll return Roll_Samples_Type is
        begin
            Execution_Time(Milliseconds(2));
            return Read_Roll;
        end getRoll;

        procedure setRoll(nuevoValor : Roll_Samples_Type) is
        begin
            Execution_Time(Milliseconds(3));
            Set_Aircraft_Roll(nuevoValor);
        end setRoll;
        
        function getPitch return Pitch_Samples_Type is
        begin
            Execution_Time(Milliseconds(2));
            return Read_Pitch;
        end getPitch;

        procedure setPitch(nuevoValor : Pitch_Samples_Type) is
        begin
            Execution_Time(Milliseconds(3));
            Set_Aircraft_Pitch(nuevoValor);
        end setPitch;

        procedure getJoystick (J: out Joystick_Samples_Type) is
        begin
            Execution_Time(Milliseconds(2));
            Read_Joystick(J);
        end getJoystick;

        procedure setJoystick(nuevoValor : Joystick_Samples_Type) is
        begin
            Execution_Time(Milliseconds(2));
            joystick := nuevoValor;
        end setJoystick;

        function getAltitude return Altitude_Samples_Type is
        begin
            Execution_Time(Milliseconds(2));
            return Read_Altitude;
        end getAltitude;

        procedure getObstacle(D: out Distance_Samples_Type) is
        begin
            Execution_Time(Milliseconds(3));
            Read_Distance(D);
        end getObstacle;

        function getPresencia return PilotPresence_Samples_Type is
        begin
            Execution_Time(Milliseconds(2));
            return Read_PilotPresence;
        end getPresencia;

        function getContador return integer is
        begin
            Execution_Time(Milliseconds(1));
            return contador;
        end getContador;

        procedure setContador (C : Integer) is
        begin
            Execution_Time(Milliseconds(1));
            contador := C;
        end setContador;
    end valores;

    task body controlVelocidad  is
        Next_Start : Ada.Real_Time.Time := Clock;
        periodo : constant Time_Span :=  Milliseconds(300);
    begin
        loop
            Start_Activity("Tarea Velocidad");
            Execution_Time(Milliseconds(3));
            Finish_Activity("Tarea Velocidad");
            Next_Start := Next_Start + periodo;
            delay until Next_Start;
        end loop;
    end controlVelocidad;

    task body controlAltCabAla is
        Next_Start : Ada.Real_Time.Time := Clock;
        periodo : constant Time_Span :=  Milliseconds(200);
    begin
        loop
            Start_Activity("Tarea Altitud+Posicion");
            Execution_Time(Milliseconds(4));
            Finish_Activity("Tarea Altitud+Posicion");
            Next_Start := Next_Start + periodo;
            delay until Next_Start;
        end loop;
    end controlAltCabAla;

    task body controlColision is
        Next_Start : Ada.Real_Time.Time := Clock;
        periodo : constant Time_Span :=  Milliseconds(250);
    begin
        loop
            Start_Activity("Tarea Colision");
            Execution_Time(Milliseconds(5));
            Finish_Activity("Tarea Colision");
            Next_Start := Next_Start + periodo;
            delay until Next_Start;
        end loop;
    end controlColision;

    task body display is
        Next_Start : Ada.Real_Time.Time := Clock;
        periodo : constant Time_Span :=  Milliseconds(1000);
    begin
        loop
            Start_Activity("Tarea Display");
            Execution_Time(Milliseconds(2));
            Finish_Activity("Tarea Display");
            Next_Start := Next_Start + periodo;
            delay until Next_Start;
        end loop;
    end display;

end fss;
