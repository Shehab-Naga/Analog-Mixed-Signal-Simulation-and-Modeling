function [symbolic_ans numeric_ans] = Solve_AMP_Circuit(netlist_directory)

%{
Part 1: reading the netlist
Part 2: parsing the netlist
Part 3: creating the matrices
Part 4: solving the matrices
%}

%__Part 1__

%loading netlist
raw_netlist = fopen(netlist_directory);
raw_netlist = fscanf(raw_netlist, '%c');

%Deleting multiple spaces, etc. using regular expressions
netlist = regexprep(raw_netlist,' *',' ');
netlist = regexprep(netlist,' I','I');
netlist = regexprep(netlist,' R','R');
netlist = regexprep(netlist,' L','L');
netlist = regexprep(netlist,' C','C');
netlist = regexprep(netlist,' V','V');
netlist = regexp(netlist,'[^\n]*','match');

%__Part 2__
%You may visit "ParseNetlist.m"
[R_Values R_Node_1 R_Node_2 R_Names] = ParseNetlist(netlist, 'R');
[L_Values L_Node_1 L_Node_2 L_Names] = ParseNetlist(netlist, 'L');
[C_Values C_Node_1 C_Node_2 C_Names] = ParseNetlist(netlist, 'C');
[V_Values V_Node_1 V_Node_2 V_Names] = ParseNetlist(netlist, 'V');
[I_Values I_Node_1 I_Node_2 I_Names] = ParseNetlist(netlist, 'I');
[E_Values E_Node_1 E_Node_2 E_Names E_Node_1_control E_Node_2_control] = ParseNetlist(netlist, 'E');
[G_Values G_Node_1 G_Node_2 G_Names G_Node_1_control G_Node_2_control] = ParseNetlist(netlist, 'G');
% Parsing the ac analysis command
[frequency] = ParseNetlist(netlist, '.AC');
%Counting nodes
%Nodes should be named in order 0, 1, 2, 3, ..
%We will combine all parsed nodes, then find the maximum number which is
%the number of nodes assuming that they are named in order

nodes_list = [R_Node_1 R_Node_2 L_Node_1 L_Node_2 C_Node_1 C_Node_2 V_Node_1 V_Node_2 I_Node_1 I_Node_2 E_Node_1 E_Node_2 G_Node_1 G_Node_2];
nodes_number = max(str2double(nodes_list));

%__Part 3__
%Matrices_size = no. nodes + no. Vsources
matrices_size = nodes_number + numel(V_Names) + numel(E_Names);

%Z matrix
%Initialize zero matrix
unit_matrix = cell(matrices_size, 1);
for i = 1:1:numel(unit_matrix)
    unit_matrix{i} = ['0'];
end
z = unit_matrix;

%stamping Isources
for I = 1:1:numel(I_Names)
    current_node_1 = str2double(I_Node_1(I));
    current_node_2 = str2double(I_Node_2(I));
    current_name = I_Names{I};
    if current_node_1 ~= 0
        z{current_node_1} = [z{current_node_1} '-' current_name];
    end
    if current_node_2 ~= 0
        z{current_node_2} = [z{current_node_2} '+' current_name];
    end
end
%stamping Vsources
for V = 1:1:numel(V_Names)
    z{nodes_number + V} = [V_Names{V}];
end
Z = str2sym(z);
%X matrix
x = cell(matrices_size, 1);
for node = 1:1:nodes_number
    x{node} = ['V_' num2str(node)];
end
%Stamping Vsources
for V = 1:1:numel(V_Names)
    x{nodes_number + V} = ['I_' V_Names{V}];
end
%Stamping VCVS
for E = 1:1:numel(E_Names)
    x{nodes_number + numel(V_Names) + E} = ['I_' E_Names{E}];
end
X = sym(x);
%A matrix
%_G matirix
G = repmat(unit_matrix(1:nodes_number), 1, nodes_number);
%Stamping R
for R = 1:1:numel(R_Names)
    current_node_1 = str2double(R_Node_1(R));
    current_node_2 = str2double(R_Node_2(R));
    current_name = R_Names{R};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+1/' current_name];
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in G matrix
        G{current_node_2, current_node_2} = [G{current_node_2, current_node_2} '+1/' current_name];
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        % add a line here to assign an element in G matrix
        G{current_node_1, current_node_2} = [G{current_node_1, current_node_2} '-1/' current_name];
        % add a line here to assign an element in G matrix
        G{current_node_2, current_node_1} = [G{current_node_2, current_node_1} '-1/' current_name];
    end
end
%Stamping L
for L = 1:1:numel(L_Names)
    current_node_1 = str2double(L_Node_1(L));
    current_node_2 = str2double(L_Node_2(L));
    current_name = L_Names{L};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+1/(i*w*' current_name ')'];
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in G matrix
        G{current_node_2, current_node_2} = [G{current_node_2, current_node_2} '+1/(i*w*' current_name ')'];
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        % add a line here to assign an element in G matrix
        G{current_node_1, current_node_2} = [G{current_node_1, current_node_2} '-1/(i*w*' current_name ')'];
        % add a line here to assign an element in G matrix
        G{current_node_2, current_node_1} = [G{current_node_2, current_node_1} '-1/(i*w*' current_name ')'];
    end
end
%Stamping C
for C = 1:1:numel(C_Names)
    current_node_1 = str2double(C_Node_1(C));
    current_node_2 = str2double(C_Node_2(C));
    current_name = C_Names{C};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+(i*w*' current_name ')'];
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in G matrix
        G{current_node_2, current_node_2} = [G{current_node_2, current_node_2} '+(i*w*' current_name ')'];
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        % add a line here to assign an element in G matrix
        G{current_node_1, current_node_2} = [G{current_node_1, current_node_2} '-(i*w*' current_name ')'];
        % add a line here to assign an element in G matrix
        G{current_node_2, current_node_1} = [G{current_node_2, current_node_1} '-(i*w*' current_name ')'];
    end
end
%Stamping VCCS
for Gsource = 1:1:numel(G_Names)
    current_node_1 = str2double(G_Node_1(Gsource));
    current_node_2 = str2double(G_Node_2(Gsource));
    current_node_1_control = str2double(G_Node_1_control(Gsource));
    current_node_2_control = str2double(G_Node_2_control(Gsource));
    current_name = G_Names{Gsource};
    if current_node_1 ~= 0
        if current_node_1_control ~= 0
            G{current_node_1, current_node_1_control} = [G{current_node_1, current_node_1_control} '+' current_name];
        end
        if current_node_2_control ~= 0
            G{current_node_1, current_node_2_control} = [G{current_node_1, current_node_2_control} '-' current_name];
        end
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in G matrix
        
        if current_node_1_control ~= 0
            G{current_node_2, current_node_1_control} = [G{current_node_2, current_node_1_control} '-' current_name];
        end
        if current_node_2_control ~= 0
            G{current_node_2, current_node_2_control} = [G{current_node_2, current_node_2_control} '+' current_name];
        end
    end
end

%B matrix
B = repmat(unit_matrix, 1, numel(V_Names)+ numel(E_Names));
%Stamping Vsource
for V = 1:1:numel(V_Names)
    current_node_1 = str2double(V_Node_1(V));
    current_node_2 = str2double(V_Node_2(V));
    if current_node_1 ~= 0
        % add a line here to assign an element in B matrix
        B{current_node_1, V} = '1';
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in B matrix
        B{current_node_2, V} = '-1';
    end
end
for E = 1:1:numel(E_Names)
    current_node_1 = str2double(E_Node_1(E));
    current_node_2 = str2double(E_Node_2(E));
    if current_node_1 ~= 0
        % add a line here to assign an element in B matrix
        B{current_node_1, numel(V_Names) + E} = '1';
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in B matrix
        B{current_node_2, numel(V_Names) + E} = '-1';
    end
end

%C matrix
C = B.';
for E = 1:1:numel(E_Names)
    current_node_1 = str2double(E_Node_1(E));
    current_node_2 = str2double(E_Node_2(E));
    current_E_Node_1_control = str2double(E_Node_1_control(E));
    current_E_Node_2_control = str2double(E_Node_2_control(E));
    if current_node_1 ~= 0
        % add a line here to assign an element in B matrix
        C{numel(V_Names) + E, current_node_1} = '1';
    end
    if current_node_2 ~= 0
        % add a line here to assign an element in B matrix
        C{numel(V_Names) + E, current_node_2} = '-1';
    end
    if current_E_Node_1_control ~= 0
        % add a line here to assign an element in B matrix
        C{numel(V_Names) + E, current_E_Node_1_control} = ['-1*' E_Names{E}];
    end
    if current_E_Node_2_control ~= 0
        % add a line here to assign an element in B matrix
        C{numel(V_Names) + E, current_E_Node_2_control} = ['1*' E_Names{E}];
    end
end

%Combining all in A matrix
a = [G; C(:,1:nodes_number)];
a = [a B];

A = str2sym(a);
%__Part 4__
%Symbolic
symbolic_ans = A\Z;
%Numeric
%Fetch variables values
numeric_ans = [];
for f = logspace(log10(str2double(frequency{1})), log10(str2double(frequency{2})), 80)
    for R=1:1:numel(R_Names)
        eval([R_Names{R} ' = ' num2str(R_Values{R}) ';']);
    end

    for L=1:1:numel(L_Names)
        eval([L_Names{L} ' = ' num2str(L_Values{L}) ';']);
    end

    for C=1:1:numel(C_Names)
        eval([C_Names{C} ' = ' num2str(C_Values{C}) ';']);
    end

    for V=1:1:numel(V_Names)
        % add a line here to assign voltage sources values into double variables
        eval([V_Names{V} ' = ' num2str(V_Values{V}) ';']);
    end

    for I=1:1:numel(I_Names)
        % add a line here to assign voltage sources values into double variables
        eval([I_Names{I} ' = ' num2str(I_Values{I}) ';']);
    end
    
    for E=1:1:numel(E_Names)
        % add a line here to assign voltage sources values into double variables
        eval([E_Names{E} ' = ' num2str(E_Values{E}) ';']);
    end
    for Gsource=1:1:numel(G_Names)
        % add a line here to assign voltage sources values into double variables
        eval([G_Names{Gsource} ' = ' num2str(G_Values{Gsource}) ';']);
    end
    
    eval(['w' ' = ' '2*pi*' num2str(f) ';']);
    numeric_ans = [numeric_ans eval(subs(symbolic_ans))];
end
%Substitute
% add a line here to substitute the symoblic solutions with the variables created in the previous step, and save it into num array
f = logspace(log10(str2double(frequency{1})), log10(str2double(frequency{2})), 80);
figure;
grid on 
title('magnitude and phase of V_{output} vs frequency')
yyaxis left
semilogx(f, 20*log10(abs(numeric_ans(1,:))));
xlabel('frequency in Hz')
ylabel('voltage magnitude in dB')
yyaxis right
semilogx(f, angle(numeric_ans(1,:))*360/(2*pi));
ylabel('phase in degree')
%=====================================================================
figure;
grid on 
title('magnitude and phase of V(2) vs frequency')
yyaxis left
semilogx(f, 20*log10(abs(numeric_ans(2,:))));
xlabel('frequency in Hz')
ylabel('voltage magnitude in dB')
yyaxis right
semilogx(f, angle(numeric_ans(2,:))*360/(2*pi));
ylabel('phase in degree')
%=====================================================================
figure;
grid on 
title('magnitude and phase of V_{input} vs frequency')
yyaxis left
semilogx(f, 20*log10(abs(numeric_ans(3,:))));
xlabel('frequency in Hz')
ylabel('voltage magnitude in dB')
yyaxis right
semilogx(f, angle(numeric_ans(3,:))*360/(2*pi));
ylabel('phase in degree')
end
