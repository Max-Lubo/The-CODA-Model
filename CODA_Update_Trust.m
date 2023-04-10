%Sctript for running the CODA model (on a von Neumann neighbourhood)
%extended to include the factor of trust. At each step the opinion update based
%on the observation is affected by the trust the agent has in the 
%observed neighbour to make the correct decision, and then such trust is also updated using a
%similar Bayesian rule.

para = struct('N',50,'alpha',0.55,'beta',0.55);
maxtime = 5000000;

%Setting up initial matrices for opinions, log opinions, trust and actions.

lattice_opinion = zeros([para.N para.N]);
lattice_op_log = zeros([para.N para.N]);
lattice_action = zeros([para.N para.N]);
lattice_trust = 0.5.*ones([para.N^2 para.N^2]);

for x=1:para.N^2*para.N^2
    lattice_trust(x,x)=1;
end


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

%Defining parameter mu - new way to make contrarian neighbours by supposing
%that they are more likely to be wrong than right (antithesis to alpha
%which denotes neigbours being percieved to be more right than wrong).
%Naturally we have mu + alpha = 1.

mu = 1-alpha;



for i=2:maxtime

 %Picking which agent to update at random.
    r_1 = randi(para.N*para.N);  
    
    %Picking a neighbour to observe at random using von Neumann neighbourhood structure.
    direction = randi(4);
    if direction == 1         
        
        %North
        if r_1 - para.N <= 0
            neighbour_act_obs =lattice_action(r_1);
            neighbour_obs_ind = r_1;
        else
            neighbour_act_obs = lattice_action(r_1 - para.N); 
            neighbour_obs_ind = r_1-para.N;
        end
        
        %East
    elseif direction == 2                                   
            
        if mod(r_1,10) == 0
           neighbour_act_obs = lattice_action(r_1);
           neighbour_obs_ind = r_1;
        else
           neighbour_act_obs = lattice_action(r_1 + 1);
           neighbour_obs_ind = r_1+1;
        end
        
        %South       
    elseif direction == 3        
             
        if r_1 + para.N > para.N*para.N
            neighbour_act_obs = lattice_action(r_1);
            neighbour_obs_ind = r_1;
        else
            neighbour_act_obs = lattice_action(r_1 + para.N);
            neighbour_obs_ind = r_1+para.N;
        end 
        
        %West       
    elseif direction == 4
        if mod(r_1-1,10) == 0
            neighbour_act_obs =lattice_action(r_1);
            neighbour_obs_ind = r_1;
        else
        neighbour_act_obs = lattice_action(r_1 - 1); 
        neighbour_obs_ind = r_1-1;
        end
    end
    
    %Setting up tau and p values before update.

   taupre =  lattice_trust(r_1,neighbour_obs_ind);
   op = lattice_opinion(r_1);
   
   %Update step for p and tau, notably not using log probabilitites anymore
   %as normal p values no longer quickly approach 0 or 1, so the computer
   %can now work with them.
   
   if neighbour_act_obs == 1
        
        lattice_opinion(r_1) = op*(taupre*para.alpha + (1-taupre)*mu)/...
                               (op*(taupre*para.alpha+(1-taupre)*mu)+...
                               (1-op)*(taupre*(1-para.alpha)+(1-taupre)*(1-mu)));
       
        lattice_trust(r_1,neighbour_obs_ind) = taupre*(op*para.alpha+ (1-op)*(1-para.alpha))...
                                        /(taupre*(op*para.alpha+(1-op)*(1-para.alpha))...
                                         +(1-taupre)*(op*mu+(1-op)*(1-mu)));
    
    
   elseif neighbour_act_obs == 0
       
        lattice_opinion(r_1) = op*(taupre*(1-para.alpha) + (1-taupre)*(1-mu))/...
                               (op*(taupre*(1-para.alpha)+(1-taupre)*(1-mu))+...
                               (1-op)*(taupre*(para.alpha)+(1-taupre)*(mu)));
       
        lattice_trust(r_1,neighbour_obs_ind) = taupre*(op*(1-para.alpha)+ (1-op)*(para.alpha))...
                                        /(taupre*(op*(1-para.alpha)+(1-op)*(para.alpha))...
                                         +(1-taupre)*(op*(1-mu)+(1-op)*(mu)));
    
     
    
   end
  
                                                        
    %Updating the decision of the agent based upon their updated opinion,
    %now using p values instead of log values as in the base model.
    
    
    if lattice_opinion(r_1) < 0.5
        lattice_action(r_1) = 0;
    else
        lattice_action(r_1) = 1; 
    end
    
    
% %Plotting the final action matrix as opinion map.
%     
% figure(2)
% C = lattice_action;
% s = pcolor(C);
% s.EdgeColor = 'none';
% colormap(gray(2))
% axis ij
% axis square
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