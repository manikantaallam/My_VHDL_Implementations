-- Synchronous FIFO 32Words - 32Bit (File: Fifo32/32.vhd)
-- This VHDL Code is written as a part of an Interview Task for Intern position
-- Written by Venkata Mani Kanta Allam (manikanta.allam@gmail.com)
-- Date of Creation 13.October.2020
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity FIFO_32 is

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
end FIFO_32;

architecture RTL of FIFO_32 is

--Memory Array Declaration
type FIFO_Cell is Array (0 to FIFO_Depth-1) of std_logic_vector(FIFO_Width-1 downto 0);

--Local Signals for FIFO_Cell
signal FIFO_Mem         :FIFO_Cell; -- := (others => (others => '0'));
signal Write_Addr_Ctr   :integer range 0 to FIFO_Depth-1 := 0;
signal Read_Addr_Ctr    :integer range 0 to FIFO_Depth-1 := 0;

--Local Signals Flags
signal Full_Int             :std_logic := '0';
signal Empty_Int            :std_logic := '0';
signal Read_Done_Int        :std_logic := '0';
signal Write_Started_Int    :std_logic := '0';
signal Data_out_Int         :std_logic_vector(FIFO_Width-1 downto 0);

begin


--Process for FIFO Internal Behaviour
  WriteToFIFO : process(Clk)
  begin
    
    if rising_edge(clk) then

      if Reset = '0' then     --Synchronous Active Low Reset
        Write_Addr_Ctr  <= 0;
        Read_Addr_Ctr   <= 0; 
        Full_Int        <='0';
        FIFO_Mem        <= (others => (others => '0'));
        Write_Started_Int <= '0';
        Read_Done_Int <= '0';
      else


   --Writing to FIFO and Setting Flags for Data Pushing System   
      if Write_Addr_Ctr  < FIFO_Depth-1 and Write_Enable = '1' then
        Write_Addr_Ctr   <= Write_Addr_Ctr + 1;
        Full_Int         <= '0';            
      elsif Write_Addr_Ctr  = FIFO_Depth-1 then
        Write_Addr_Ctr    <= 0;
        Full_Int          <= '1';
      else
        Write_Addr_Ctr    <= 0;
        Full_Int          <='0';
      end if;
      FIFO_Mem(Write_Addr_Ctr) <= Data_In; 

      if (Write_Addr_Ctr > 1) and (Write_Addr_Ctr < FIFO_Depth-1) then
        Write_Started_Int <= '1';
      else
        Write_Started_Int <= '0';
      end if;


  --Reading from FIFO and Setting Flags for Data Pulling System 
      if Read_Addr_Ctr < FIFO_Depth-1 and Read_Enable = '1' then
        Read_Addr_Ctr <= Read_Addr_Ctr + 1;
        Empty_Int     <='0';
      elsif Read_Addr_Ctr = FIFO_Depth-1 then
        Read_Addr_Ctr <= 0;
        Empty_Int <= '1';
      else
        Read_Addr_Ctr <= 0;
        Empty_Int <= '0';
      end if;
      Data_out_Int <= FIFO_Mem (Read_Addr_Ctr);


      end if;      
    end if; -- Syncrounous
  end process; -- Write&Read - FIFO32


--Concurrent Statements for internal Signals and Ports
Data_out <= Data_out_Int when Read_Enable = '1' else (others => '0');
Full    <= '1' when Full_Int = '1' else '0';
Empty   <= '1' when Empty_Int = '1' else '0';

--To notify the Data Pushing system for Data Reading Completion
Read_Done     <= '1' when  Empty_Int = '1' else '0';

--To notify the Data Pulling System for the New Data Availability 
Write_Started <= '1' when Write_Started_Int = '1' and Write_Enable = '1'  else '0';

end RTL;