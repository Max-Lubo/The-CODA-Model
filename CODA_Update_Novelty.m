%Script for the CODA model on a von Neumann neighbourhood extended to 
%account for the lack of familiarity agents have with a new innovations 
%diminishing the effect of observations of non-adoption, up until the end of a given
%"Novelty period" of length T, with diminishing returns as the end of the novelty period is approached.

para = struct('N',50,'alpha',0.55,'beta',0.55,'T',10000);
maxtime = 5000000;

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


for k=1:maxtime

%Picking which agent to update
    r_1 = randi(para.N*para.N);
    %Picking their neighbour using von Neumann neighbourhood structure
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
    
    %Checking to see if the model is still within the novelty period, and
    %if so defining the limiting factor rho according to how far through
    %the novelty period the model has progressed.
    
    if k < T
        rho = k/T;
    else
        rho = 1;
    end
    
    %Updating agent opinion, making sure to account for the novelty factor
    %(only applying to observations of non-adoption).
    
    if neighbour_act_obs == 1
        lattice_op_log(r_1) = lattice_op_log(r_1) + log(para.alpha/(1-para.beta));
    elseif neighbour_act_obs == 0
        lattice_op_log(r_1) = lattice_op_log(r_1) - log((rho*para.beta+(1-rho))...
                                                         /(rho*(1-para.alpha)+(1-rho)));
    
    end

        %Updating the action of the agent based upon their new updated
        %opinion.
    
    if lattice_op_log(r_1) < 0
        lattice_action(r_1) = 0;
    else
        lattice_action(r_1) = 1; 
    end
    
    end
    
%     %Plotting the final action matrix as opinion map - also allowing it to show
%     %model running in real time.
%     
%     figure(2)
%     C = lattice_action;
%     s = pcolor(C);
%     s.EdgeColor = 'none';
%     colormap(gray(2))
%     axis ij;
%     axis square;


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
    
  
% nu = log(para.alpha/(1-para.alpha));
% 
% lat_op_dist = 1/nu .* lattice_op_log;

% figure(3)
% histogram(lattice_opinion(:),'numbins',50,'normalization','probability')