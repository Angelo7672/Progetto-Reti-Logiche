----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Angelo Attivissimo
-- 
-- Create Date: 09/28/2022 10:32:43 PM
-- Design Name: 
-- Module Name: 10667094 - Behavioral
-- Project Name: Progetto Reti Logiche
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    component datapath is
        port ( 
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_data : in std_logic_vector(7 downto 0);
            o_data : out std_logic_vector (7 downto 0);
            r1_load : in std_logic;
            r2_load : in std_logic;
            r3_load : in std_logic;
            r4_load : in std_logic;
            r5_load : in std_logic;
            r6_load : in std_logic;
            r7_load : in std_logic;
            r1_sel : in std_logic;
            r2_sel : in std_logic;
            r4_sel : in std_logic;
            r5_sel : in std_logic;
            r6_sel : in std_logic;
            o_end : out std_logic;
            end_word : out std_logic;
            fsm_go : in std_logic;
            rst_fsm : in std_logic;
            o_rm : out std_logic_vector(15 downto 0);
            o_wm : out std_logic_vector(15 downto 0)
        );
    end component;
    
    signal r1_load : std_logic;
    signal r2_load : std_logic;
    signal r3_load : std_logic;
    signal r4_load : std_logic;
    signal r5_load : std_logic;
    signal r6_load : std_logic;
    signal r7_load : std_logic;

    signal r1_sel : std_logic;
    signal r2_sel : std_logic;
    signal r4_sel: std_logic;
    signal r5_sel : std_logic;
    signal r6_sel : std_logic;

    signal o_end : std_logic;
    signal end_word : std_logic;
    signal fsm_go : std_logic;
    signal rst_fsm : std_logic;

    signal o_rm : std_logic_vector(15 downto 0);
    signal o_wm : std_logic_vector(15 downto 0);

    type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15);
    signal cur_state, next_state : S;

    begin

        DATAPATH0 : datapath port map(
            i_clk,
            i_rst,
            i_data,
            o_data,
            r1_load,
            r2_load,
            r3_load,
            r4_load,
            r5_load,
            r6_load,
            r7_load,
            r1_sel,
            r2_sel,
            r4_sel,
            r5_sel,
            r6_sel,
            o_end,
            end_word,
            fsm_go,
            rst_fsm,
            o_rm,
            o_wm
        );

        process(i_clk,i_rst)
        begin
            if(i_rst = '1') then
                cur_state <= S0;
            elsif i_clk'event and i_clk = '1' then
                cur_state <= next_state;
            end if;
        end process;
        
        process(cur_state,i_start,o_end,end_word)
        begin
            next_state <= cur_state;
            case cur_state is
                when S0 =>
                    if i_start = '1' then
                        next_state <= S1;
                    end if;
                when S1 =>
                    next_state <= S2;
                when S2 =>
                    next_state <= S3;
                when S3 =>
                    next_state <= S4;
                when S4 =>
                    if o_end = '0' then
                        next_state <= S5;
                    else 
                        next_state <= S15;
                    end if;
                when S5 =>
                    next_state <= S6;
                when S6 =>
                    next_state <= S7;
                when S7 =>
                    next_state <= S8;
                when S8 =>
                    next_state <= S9;
                when S9 =>
                    next_state <= S10;
                when S10 =>
                    next_state <= S11;
                when S11 =>
                    next_state <= S12;
                when S12 =>
                    next_state <= S13;
                when S13 =>
                    if o_end = '1' and end_word = '1' then
                        next_state <= S15;
                    elsif o_end = '0' and end_word = '1' then
                        next_state <= S5;
                    elsif end_word = '0' then
                        next_state <= S14;
                    end if;
                when S14 =>
                    next_state <= S9;
                when S15 =>
                    next_state <= S0;
            end case;
        end process;

    process(cur_state,o_rm,o_wm)
    begin
        --memoria
        r5_sel <= '0';
        r5_load <= '0';
        r6_sel <= '0';
        r6_load <= '0';
        o_address <= "0000000000000000";
        o_en <= '0';
        o_we <= '0';

        --contatore generale
        r1_sel <= '0';
        r1_load <= '0';

        --registro parola
        r3_load <= '0';
        
        --contatore index parola
        r2_sel <= '0';
        r2_load <= '0';

        --parola in uscita
        r4_sel <= '0';
        r4_load <= '0';
        fsm_go <= '0';
        rst_fsm <= '0';
        r7_load <= '0';
        o_done <= '0';

        case cur_state is
            when S0 =>  --idle
            when S1 =>
                r5_sel <= '0'; 
                r5_load <= '1'; --inizializzo indirizzo lettura
                r6_sel <= '0';
                r6_load <= '1'; --inizializzo indirizzo scrittura
                rst_fsm <= '1'; --resetto convolutore
            when S2 =>  --accedo in memoria
                o_en <= '1';
                o_address <= o_rm;
                r6_load <= '0';
                r5_load <= '0';
                rst_fsm <= '0';
            when S3 =>
                o_en <= '0';
                r1_load <= '1'; --carico il #parole
            when S4 =>  --e' disponibile il #parole
            when S5 =>
                r5_sel <='1';
                r5_load <= '1'; --pronto a leggere nuovo indirizzo memoria
            when S6 =>
                r5_load <= '0';
                r1_sel <= '1';  
                r1_load <= '1'; --faccio decrementare il contatore generale
                o_en <= '1';
                o_address <= o_rm;  --pronto per leggere parola in memoria
                r2_sel <= '0';  --inizializzo contatore index parola
                r2_load <= '1';
            when S7 =>
                r1_load <= '0';
                r3_load <= '1'; --carico nuova parola
                r2_load <= '0';
            when S8 =>  --1/4   --viene preparato il primo o_fsm
                r2_sel <= '1';
                r2_load <= '1';
                fsm_go <= '1';
            when S9 =>  --2/4             
                r4_load <= '1';
                r2_sel <= '1';
                r2_load <= '1';
                fsm_go <= '1';
            when S10 =>  --3/4               
                r4_load <= '1';
                r2_sel <= '1';
                r2_load <= '1';
                fsm_go <= '1';
            when S11 => --4/4              
                r4_load <= '1';
                r2_sel <= '1';
                r2_load <= '1';
                fsm_go <= '1';
            when S12 =>
                r7_load <= '1'; --una nuova parola e' pronta per essere scritta in memoria
                r4_sel <= '1';  --inizializzo r4
                r4_load <= '1';
                r2_load <= '0';
                fsm_go <= '0';               
            when S13 => --scrivi in memoria
                o_address <= o_wm;
                o_en <= '1';
                o_we <= '1';    --scrivi parola in memoria
                r6_sel <= '1';
                r6_load <= '1'; --carico prossimo indirizzo scrittura
            when S14 => --1/4 per la seconda semi parola
                r4_sel <= '0';
                r4_load <= '1';
                r2_sel <= '1';
                r2_load <= '1';
                fsm_go <= '1';  --rimette in funzione il convolutore
            when S15 =>
                o_done <= '1';
        end case;
        end process;
    
end Behavioral;

--DATAPATH
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
    port( 
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_data : out std_logic_vector (7 downto 0);
        r1_load : in std_logic;
        r2_load : in std_logic;
        r3_load : in std_logic;
        r4_load : in std_logic;
        r5_load : in std_logic;
        r6_load : in std_logic;
        r7_load : in std_logic;
        r1_sel : in std_logic;
        r2_sel : in std_logic;
        r4_sel : in std_logic;
        r5_sel : in std_logic;
        r6_sel : in std_logic;
        o_end : out std_logic;
        end_word : out std_logic;
        fsm_go : in std_logic;
        rst_fsm : in std_logic;
        o_rm : out std_logic_vector(15 downto 0);
        o_wm : out std_logic_vector(15 downto 0)
    );
end datapath;

architecture Behavioral of datapath is

    component convolutore is 
        port(
            r3_sgn : in std_logic;
            i_clk : in std_logic;
            i_rst : in std_logic;
            o_fsm : out std_logic_vector(1 downto 0);
            fsm_go : in std_logic;
            rst_fsm : in std_logic
        );
    end component;

    signal o_reg1 : std_logic_vector (7 downto 0);
    signal mux_reg1 : std_logic_vector (7 downto 0);
    signal sub_reg1 : std_logic_vector (7 downto 0);

    signal o_reg2 : unsigned (2 downto 0);
    signal mux_reg2 : unsigned (2 downto 0);
    signal sub_reg2 : unsigned (2 downto 0);

    signal o_reg3 : std_logic_vector (7 downto 0);
    signal r3_sgn : std_logic;

    signal o_fsm : std_logic_vector (1 downto 0);
    signal o_reg4 : std_logic_vector (7 downto 0);
    signal mux_reg4 : std_logic_vector (7 downto 0);
    signal to_add : std_logic_vector (7 downto 0);
    signal c_word : std_logic_vector (7 downto 0);

    signal o_reg7 : std_logic_vector (7 downto 0);

    signal o_reg5 : std_logic_vector (15 downto 0);
    constant address_reset_rm: std_logic_vector(15 downto 0) := "0000000000000000"; --per una diversa prima cella di memoria per lettura, modificare la costante
    signal mux_reg5 : std_logic_vector (15 downto 0);
    signal sum_reg5 : std_logic_vector (15 downto 0);
    
    signal o_reg6 : std_logic_vector (15 downto 0);
    constant address_reset_wm: std_logic_vector(15 downto 0) := "0000001111101000"; --per una diversa prima cella di memoria per scrittura, modificare la costante
    signal mux_reg6 : std_logic_vector (15 downto 0);
    signal sum_reg6 : std_logic_vector (15 downto 0);
    
begin
    CONVOLUTORE0 : convolutore port map(
        r3_sgn,
        i_clk,
        i_rst,
        o_fsm,
        fsm_go,
        rst_fsm
    );

    --contatore generale
    with r1_sel select
        mux_reg1 <= i_data when '0',
                    sub_reg1 when '1',
                    "XXXXXXXX" when others;
    
    process(i_clk,i_rst,o_reg1)
    begin
        if(i_rst = '1') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= mux_reg1;                    
            end if;
        end if;
        if(o_reg1 = "00000000") then
            o_end <= '1';
        else
            o_end <= '0';
        end if;
    end process;

    sub_reg1 <= o_reg1 - "00000001";

    --registro parola
    process(i_clk,i_rst)
    begin
        if(i_rst = '1') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3 <= i_data;                    
            end if;
        end if;
    end process;

    --contatore index parola
    with r2_sel select
        mux_reg2 <= "111" when '0',
                    sub_reg2 when '1',
                    "XXX" when others;
    
    process(i_clk,i_rst,o_reg2)
    begin
        if(i_rst = '1') then
            o_reg2 <= "000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= mux_reg2;                    
            end if;
        end if;
        if(o_reg2 = "111") then
            end_word <= '1';
        else
            end_word <= '0';
        end if;
    end process;

    sub_reg2 <= o_reg2 - "001";

    r3_sgn <= o_reg3(to_integer(o_reg2));

    --parola in uscita
    with r4_sel select
        mux_reg4 <= "00000000" when '1',
                    c_word when '0',
                    "XXXXXXXX" when others;
    
    process(i_clk,i_rst)
    begin
        if(i_rst = '1') then
            o_reg4 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r4_load = '1') then
                o_reg4 <= mux_reg4;                    
            end if;
        end if;
    end process;

    to_add <= std_logic_vector(shift_left(unsigned(o_reg4), 2));

    c_word <= to_add + o_fsm;

    process(i_clk,i_rst)
    begin
        if(i_rst = '1') then
            o_reg7 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r7_load = '1') then 
                o_reg7 <= c_word;                    
            end if;
        end if;
    end process;

    o_data <= o_reg7;

    --contatore rm
    with r5_sel select
        mux_reg5 <= address_reset_rm when '0',
                    sum_reg5 when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    process(i_clk,i_rst)
    begin
        if(i_rst = '1') then
            o_reg5 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r5_load = '1') then
                o_reg5 <= mux_reg5;                    
            end if;
        end if;
    end process;
    
    o_rm <= o_reg5;

    sum_reg5 <= o_reg5 + "0000000000000001";

    --contatore wm
    with r6_sel select
        mux_reg6 <= address_reset_wm when '0',
                    sum_reg6 when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    process(i_clk,i_rst)
    begin
        if(i_rst = '1') then
            o_reg6 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r6_load = '1') then
                o_reg6 <= mux_reg6;                    
            end if;
        end if;
    end process;
    
    o_wm <= o_reg6;

    sum_reg6 <= o_reg6 + "0000000000000001";

end Behavioral;

--CONVOLUTORE
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity convolutore is
    port( 
        r3_sgn : in std_logic;
        i_clk : in std_logic;
        i_rst : in std_logic;
        o_fsm : out std_logic_vector(1 downto 0);
        fsm_go : in std_logic;
        rst_fsm : in std_logic
    );
end convolutore;

architecture rtl of convolutore is

    type STATUS is (S0,S1,S2,S3);
    signal PS, NS: STATUS;
    signal Y: std_logic_vector(1 downto 0);

begin

    -- Next state and output
    delta_lambda: process(PS,r3_sgn)
    begin
        case PS is
            when S0 =>
                if(r3_sgn = '0') then
                    NS <= S0;
                    Y <= "00";
                else
                    NS <= S2;
                    Y <= "11";
                end if;
            when S1 =>
                if(r3_sgn = '0') then
                    NS <= S0;
                    Y <= "11";
                else
                    NS <= S2;
                    Y <= "00";
                end if;
            when S2 =>
                if(r3_sgn = '0') then
                    NS <= S1;
                    Y <= "01";
                else
                    NS <= S3;
                    Y <= "10";
                end if;
            when S3 =>
                if(r3_sgn = '0') then
                    NS <= S1;
                    Y <= "10";
                else
                    NS <= S3;
                    Y <= "01";
                end if;
            when others =>
                NS <= S0;
                Y <= "00";
        end case;
    end process;

    -- State register
    state: process(i_clk,fsm_go)
    begin
        if(i_clk'event and i_clk = '1') then
            if(i_rst = '1' or rst_fsm = '1') then
                PS <= S0;
            elsif(fsm_go = '1') then
                    PS <= NS;
            end if;
        end if;
    end process;

    -- Output register
    output: process(i_clk,fsm_go,rst_fsm)
    begin
        if(i_clk'event and i_clk = '1') then
            if(i_rst = '1' or rst_fsm = '1') then
                o_fsm <= "00";
            elsif(fsm_go = '1') then
                o_fsm <= Y;
            end if;
        end if;
    end process;
end rtl;
