%Script for running the CODA model on a Moore neighbourhood (8 neighbours)
%as opposed to a von Neumann neighbourhood (4 neighbours), noting that
%agents on the boundary of the lattice are still mirrored when making an
%observation off of the lattice.
clear all

para = struct('N',50,'alpha',0.55,'beta',0.55);
maxtime = 5000000;

%Setting up initial matrices for opinions, log opinions and actions.

lattice_opinion = zeros([para.N para.N]);
lattice_op_log = zeros([para.N para.N]);
lattice_action = zeros([para.N para.N]);


%Assigning initial random moderate opinion values.

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



%Plotting the initial opinion map.

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
    
    %Picking their neighbour using a Moore neighbourhood structure
    direction = randi(8);
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
    elseif direction == 4
        if mod(r_1-1,10) == 0
            neighbour_act_obs =lattice_action(r_1);
        else
        neighbour_act_obs = lattice_action(r_1 - 1);  
        end
        
        %North-East
    elseif direction == 5
        if  (mod(r_1,10) == 0 || r_1 - para.N <= 0)
            neighbour_act_obs = lattice_action(r_1);
        else
            neighbour_act_obs = lattice_action(r_1 -para.N +1);
        end
        
        %South-East
    elseif direction == 6
        if ( mod(r_1,10) == 0 || r_1 + para.N > para.N*para.N)
            neighbour_act_obs = lattice_action(r_1);
        else
            neighbour_act_obs = lattice_action(r_1 +para.N +1);
        end
        
        %South-West
    elseif direction == 7
        if ( mod(r_1-1,10) == 0 || r_1 + para.N > para.N*para.N)
            neighbour_act_obs = lattice_action(r_1);
        else
            neighbour_act_obs = lattice_action(r_1 +para.N -1);
        end
        
        %North-West
    elseif direction == 8
        if  (mod(r_1-1,10) == 0 || r_1 - para.N <= 0)
            neighbour_act_obs = lattice_action(r_1);
        else
            neighbour_act_obs = lattice_action(r_1 -para.N -1);
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
% %Plotting the final action matrix as opinion map.
%     
% figure(2)
% C = lattice_action;
% pcolor(C);
% colormap(gray(2));
% axis ij;
% axis square;
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

%Specifically for the alpha = beta scenarios (which are the primary focus),
%Defining new parameter nu to show how far each agent if from changing
%opinion.

nu = log(para.alpha/(1-para.alpha));

lat_op_dist = 1/nu .* lattice_op_log;

figure(3)
histogram(lat_op_dist(:),'numbins',15,'normalization','probability')

