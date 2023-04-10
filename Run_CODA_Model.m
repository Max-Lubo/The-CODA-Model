%Script for running the base CODA model (i.e no extensions, just the
%Bayesian opinion updating step and decision displaying, with distance from
%changing opinion histogram. Note: for agents on the edge of the lattice,
%when trying to make an observation off of the lattice, they are modelled
%as "looking in a mirror" - that is they observe their own action and
%reinforce their opinion consequently.

%Alpha and beta denote the likelihood that an observation of a neighbour
%choosing choice A or choice B was the correct choice for them to make -
%for the base case, agents should assume they're neighbours are trustowrthy
%and that either action holds equal weight, so we set beta = alpha > 0.5.

para = struct('N',50,'alpha',0.55,'beta',0.55);
maxtime = 50000000;

%Setting up initial matrices for opinions, log opinions and agent actions.

lattice_opinion = zeros([para.N para.N]);
lattice_op_log = zeros([para.N para.N]);
lattice_action = zeros([para.N para.N]);


%Assigning initial random moderate opinion values toward either of the
%choices, and defining inital agent actions as a result.

tic
for i=1:para.N
    a = 0.45;
    b = 0.55;
    r = (b-a).*rand(para.N,1) + a;
    lattice_opinion(i,:)=r;
    
    
    
    for j=1:para.N
        lattice_op_log(i,j)=log(lattice_opinion(i,j)/(1-lattice_opinion(i,j)));
        if lattice_op_log(i,j)<0
            lattice_action(i,j)=0;
            
        else
            lattice_action(i,j)=1;
        end
    end
end



%Plotting the initial opinion map as a comparator for later.

figure(1)
C = lattice_action;
s = pcolor(C);
s.EdgeColor = 'none';
colormap(gray(2))
axis ij
axis square

for i=2:maxtime

 %Picking which agent to update
    r_1 = randi(para.N*para.N);  
    
    %Picking their neighbour using a von Neumann neighbourhood structure 
    %NOTE - THIS METHOD WORKS FOR N DIVISIBLE BY 10, NEED TO FIND A WAY TO
    %IDENTIFY EDGE CASES FOR GENERAL N - REPLACE 10 BY para.N?

    direction = randi(4);
    if direction == 1         
        
        %North
        if r_1 - para.N <= 0
            neighbour_act_obs =lattice_action(r_1);
        else
            neighbour_act_obs = lattice_action(r_1 - para.N);     
        end
        
        %East
    elseif direction == 2                                   
            
        if mod(r_1,10) == 0
           neighbour_act_obs = lattice_action(r_1);
        else
           neighbour_act_obs = lattice_action(r_1 + 1);
        end
        
        %South       
    elseif direction == 3        
             
        if r_1 + para.N > para.N*para.N
            neighbour_act_obs = lattice_action(r_1);
        else
            neighbour_act_obs = lattice_action(r_1 + para.N);
        end 
        
        %West       
    else
        if mod(r_1-1,10) == 0
            neighbour_act_obs =lattice_action(r_1);
        else
        neighbour_act_obs = lattice_action(r_1 - 1);  
        end
    end
    
        %Enacting the Bayesian opinion update rule based upon the action
        %which was observed
    
    if neighbour_act_obs == 1
        lattice_op_log(r_1) = lattice_op_log(r_1) + log(para.alpha/(1-para.beta));
    elseif neighbour_act_obs == 0
        lattice_op_log(r_1) = lattice_op_log(r_1) - log(para.beta/(1-para.alpha));                                                    
    end
    
        %Updating the action of the agent based upon their new updated
        %opinion.
    
    if lattice_op_log(r_1) < 0
        lattice_action(r_1) = 0;
    else
        lattice_action(r_1) = 1; 
    end
    
    
% %Plotting the final action matrix as opinion map - also allowing it to show
% %model running in real time.
%     
% figure(2)
% C = lattice_action;
% s = pcolor(C);
% s.EdgeColor = 'none';
% colormap(gray(2))
% axis ij;
% axis square;

%Optional time counter to track the progress of the model.

%i
end

%Plotting the final action matrix as opinion map.

figure(2)
C = lattice_action;
s = pcolor(C);
s.EdgeColor = 'none';
colormap(gray(2))
axis ij
axis square
toc

%Defining new parameter nu to show how far each agent if from changing
%opinion.

nu = log(para.alpha/(1-para.beta));

lat_op_dist = 1/nu .* lattice_op_log;

figure(3)
histogram(lat_op_dist(:,:),'numbins',15,'normalization','probability')