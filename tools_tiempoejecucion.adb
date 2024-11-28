
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with Workload;

package body tools is

---------------------------------------------------------------------
--     PROCEDIMIENTO QUE IMPRIME LA HORA                           --
---------------------------------------------------------------------
    procedure Current_Time (Origen : Ada.Real_Time.Time)is
    begin
      Put_Line ("");
      Put ("[");
      Kernel.Serial_Output.Put(Duration'Image(To_Duration(Clock - Origen)));
      Put ("] ");
    end Current_Time;

    procedure Print_Chrono is      
    begin
      Put_Line ("");
      Put ("[");
      Kernel.Serial_Output.Put(Duration'Image(To_Duration(Clock - Big_Bang))(1..7));
      Put ("] ");
    end Print_Chrono;
    
---------------------------------------------------------------------
--     PROCEDIMIENTO QUE SACA EL VALOR DE UN ENTERO POR LA UART    --
---------------------------------------------------------------------

   procedure Print_an_Integer (x : in integer) is
     begin
      Kernel.Serial_Output.Put (Integer'Image(x));
    end Print_an_Integer;

---------------------------------------------------------------------
--     PROCEDIMIENTO QUE SACA EL VALOR DE UN FLOAT POR LA UART    --
---------------------------------------------------------------------

   procedure Print_a_Float (x : in float) is
       type Float_Printable is digits 2; 
       nx: Float_Printable;
     begin
      nx := Float_Printable (x);
      Kernel.Serial_Output.Put (Float_Printable'Image(nx));
    end Print_a_Float;

   procedure Print_a_String (s: in String) is
   begin
      Print_Chrono;     
      Put (" ");
      Put (s);
   end Print_a_String;
   
---------------------------------------------------------------------
--     PROCEDIMIENTO PARA AVISAR DEL ARRANQUE DE UNA TAREA         --
---------------------------------------------------------------------

   procedure Start_Activity (T: in String) is
   begin
      Print_Chrono;
      Put (">>> ");
      Put (T);
   end Start_Activity;

   procedure Finish_Activity (T: in String) is
   begin
      Print_Chrono;
      Put ("--- ");
      Put (T);
   end Finish_Activity;

---------------------------------------------------------------------
--     PROCEDIMIENTO QUE HACE CALCULOS                             --
---------------------------------------------------------------------
   Time_per_Kwhetstones : constant Ada.Real_Time.Time_Span :=
                        Ada.Real_Time.Nanoseconds (660_000);

   procedure Execution_Time (Time : Ada.Real_Time.Time_Span) is
   begin
      Workload.Small_Whetstone (Time / Time_per_Kwhetstones);
   end Execution_Time;
---------------------------------------------------------------------

begin
    null;
end tools;
