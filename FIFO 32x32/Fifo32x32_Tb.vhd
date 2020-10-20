-- Synchronous FIFO 32Words - 32Bit Testbench (File: Fifo32/32_tb.vhd)
-- This VHDL Code is written as a part of an Interview Task for Intern position
-- Written by Venkata Mani Kanta Allam (manikanta.allam@gmail.com)
-- Date of Creation 13.October.2020
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Tb_FIFO_32 is
end Tb_FIFO_32;

architecture Test of Tb_FIFO_32 is

--Internal Signals _ Generics
    constant FIFO_Width: integer := 32;
    constant FIFO_Depth: integer := 32;
 
-- Internal Signals for DUT
    --Common Clock & Reset
    signal S_Clk     : std_logic;
    signal S_Reset   : std_logic;

    --Clock Frequency
    constant Clk_period : time := 10 ns;
  
    --Write Side Ports
    signal S_Write_Enable  :  std_logic;
    signal S_Data_in       :  std_logic_vector(FIFO_Width-1 downto 0);
    signal S_Full          :  std_logic;
    Signal S_Read_Done       : std_logic;
  
    --Read Side Ports
    signal S_Read_Enable   :  std_logic;
    signal S_Data_out      :  std_logic_vector(FIFO_Width -1 downto 0);
    signal S_Empty         :  std_logic;
    SIgnal S_Write_Started :  std_logic;

--Component Declaration
  component FIFO_32 is

    generic (
    FIFO_Width: integer := 32;
    FIFO_Depth: integer := 32
    );
  
    port (
      --Common Clock & Reset
      Clk     :in std_logic;
      Reset   :in std_logic;
    
      --Write Side Ports
      Write_Enable  :in   std_logic;
      Data_in       :in   std_logic_vector(FIFO_Width-1 downto 0);
      Full          :out  std_logic;
      Read_Done     :Out  std_logic;
    
      --Read Side Ports
      Read_Enable   :in   std_logic;
      Data_out      :out  std_logic_vector(FIFO_Width -1 downto 0);
      Empty         :out  std_logic;
      Write_Started :Out  std_logic
      );


  end component FIFO_32;

begin

--Instantiation
DUT: FIFO_32
Generic map (FIFO_Width => FIFO_Width,FIFO_Depth => FIFO_Depth)
Port map(S_Clk, S_Reset, S_Write_Enable, S_Data_in, S_Full, S_Read_Done, S_Read_Enable, S_Data_out, S_Empty, S_Write_Started);


--Process for  Clock Generation
Clock_process :process
begin
  S_Clk <= '0';
     wait for Clk_period/2;
  S_Clk <= '1';
     wait for Clk_period/2;
end process;



-- Testing input feeding Vectors & Assertion of Correct Results


--Reset/Clear the FIFO  (Active Low Reset) 
Clearing_FIFO: process 
begin
wait for 50 ns;  
S_Reset <='0';
wait for 30 ns;
S_Reset <='1';
wait;
end process; 



--Enable Writing and Write to the FIFO 
WriteToFIFO : process
begin
wait for 90 ns;
S_Write_Enable <='1';
S_Data_in <= (others=> '0');
for i in 0 to FIFO_Depth-1 loop
  wait for 10 ns;
  S_Data_in <= std_logic_vector(unsigned(S_Data_in) + 1);
  --wait for 10 ns;
  end loop;
  S_Write_Enable <='0';
  wait;
  
end process;



--Enable the Reading Process
Reading : process
begin 
  wait for 115 ns;
  S_Read_Enable <= '1';
  wait for 320 ns;
  S_Read_Enable <= '0';
  wait;
end process;


end architecture; -- End of Architecture












--Wait for 8ns;