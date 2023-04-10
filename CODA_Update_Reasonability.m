%Script for running the CODA model (on a von Neumann neigbourhood) extended
%to account for agent rationality. It is assumed that every agent has a
%certain bias towards one of the options, and so there is a chance in every
%interaction that the observed choice may have been made purely in
%accordance with this personal bias. Thus, a new parameter lambda is
%defined to signify the "reasonable" agents. Consequently, the probabilities
%used in Bayes Theorem must be updated to include this reasonability factor
%lambda, and so the opinion update rule changes slightly.

%PERSONAL NOTE: Similar to the trust extension - much easier to understand and
%implement, at least in the ways in which I have done it. 

para = struct('N',50,'alpha',0.6,'beta',0.9);
maxtime = 1000000;

%Setting up initial matrices for opinions, log opinions and actions.

lattice_opinion = zeros([para.N para.N]);
lattice_op_log = zeros([para.N para.N]);
lattice_action = zeros([para.N para.N]);


%Assigning initial random moderate opinion values.

tic
for i=1:para.N
    a = 0.4;
    b = 0.6;
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

%Assume every agent has a preferred choice between the options.
%Defining lamba - the proportion of agents that act reasonably, as in the
%base CODA model (so a proportion of (1-lambda) of the population choose their preferred
%choice more whether it is correct to or not with probability beta).
%Also define probabilities for each choice of agent i given which of the
%options was the better choice.

%CX_Y Denotes an observation of choice X, given that choice Y was the
%correct opiton to choose.

lambda = 0.8;

CA_A = lambda*para.alpha +(1-lambda)*(1-para.beta); %Reasonable, picked better option A + Unreasonable,not chosen its bias B.
CA_B = lambda*(1-para.alpha) + (1-lambda)*(1-para.beta); %Reasonable, not picked better option B + Unreasonable, not chosen its bias B.
CB_A = lambda*(1-para.alpha) +(1-lambda)*para.beta; %Reasonable, not picked better opiton A + Unreasonable, chosen its bias B.
CB_B = lambda*para.alpha + (1-lambda)*para.beta; %Reasonable, picked better option B + Unreasonable, chosen its bias B.


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
    
    %Storing previous opinion.

    op_pre = lattice_opinion(r_1);
    
    %Positive action is towards A, non positve action is towards B.
    %Updating opinion based on observation - new update step to account for
    %rationality.
    
    if neighbour_act_obs == 1
        lattice_opinion(r_1) = (op_pre*CA_A)/(op_pre*CA_A+(1-op_pre)*CA_B);
    elseif neighbour_act_obs == 0
        lattice_opinion(r_1) = (op_pre*CB_B)/(op_pre*CB_B+(1-op_pre)*CB_A);
    end 

    %Updating the action of the agent based on their updated opinion (using
    %p values).
    
    if lattice_opinion(r_1) < 0.5
        lattice_action(r_1) = 0;
    else
        lattice_action(r_1) = 1; 
    end
    
    
    
%%%%%%%%    Could also do this using the log method  %%%%%%%%
%
%          if neighbour_act_obs == 1
%         lattice_op_log(r_1) = lattice_op_log(r_1) + log(CA_A/CA_B);
%          elseif neighbour_act_obs == 0
%         lattice_op_log(r_1) = lattice_op_log(r_1) - log(CB_B/CB_A);
%          end
%          
%          if lattice_op_log(r_1) < 0
%         lattice_action(r_1) = 0;
%          else
%         lattice_action(r_1) = 1; 
%          end
        
        
                                                   
%Plotting the final action matrix as opinion map - also allowing it to show
%model running in real time.
    
figure(2)
C = lattice_action;
s = pcolor(C);
s.EdgeColor = 'none';
colormap(gray(2))
axis ij;
axis square;
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

% nu = log(para.alpha/(1-para.beta));
% 
% lat_op_dist = 1/nu .* lattice_op_log;
% 
% figure(3)
% histogram(lat_op_dist(:),'numbins',15,'normalization','probability')