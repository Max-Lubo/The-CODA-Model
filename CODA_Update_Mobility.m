%Script for running the CODA model (on a von Neumann neighbourhood)
%extended to account for the mobility of agents. Every "f" timesteps two
%agents are chosen at random to swap places within the population lattice,
%thereby representing real-life migration of agent,s who certainly don't stay
%in the same place all the time.
clear all

para = struct('N',50,'alpha',0.55,'beta',0.55);
maxtime = 5000000;

%Setting up initial matrices for opinions,log opinions and actions.

lattice_opinion = zeros([para.N para.N]);
lattice_op_log = zeros([para.N para.N]);
lattice_action = zeros([para.N para.N]);

%Define mobility parameter "f", representing the number of updates after
%which migration occurs. Lower f => consensus, as everyone tends to be affected by
%everyone else. Higher f tends to have little effect on dynamics (Note -
%here f is being compared to the maxtime of the model).

f = 500;

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

 %Picking which agent to update.
    r_1 = randi(para.N*para.N);  
    
    %Picking their neighbour using von Neumann neighbourhood structure.
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
    
  %Introducing basic mobility every f timesteps, at such times two agents
  %are chosen at random to swap positions in the lattice.
  
  if (mod(i,f) == 0)
      mob_indices = randperm(para.N*para.N,2);
      op_log_index_1 = lattice_op_log(mob_indices(1));
      
      lattice_op_log(mob_indices(1)) = lattice_op_log(mob_indices(2));
      lattice_op_log(mob_indices(2)) = op_log_index_1;
  else
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

nu = log(para.alpha/(1-para.alpha));

lat_op_dist = 1/nu .* lattice_op_log;

figure(3)
histogram(lat_op_dist(:),'numbins',15,'normalization','probability')