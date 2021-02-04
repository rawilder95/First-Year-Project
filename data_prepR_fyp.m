clc;
clear all;
close all;
%this is actually important
target_dir= '/Users/rebeccawilder/Desktop/first-year-project';
current_dir= pwd;

if ~strcmp(current_dir, target_dir)
    cd(target_dir)
end
addpath(genpath('/Users/rebeccawilder/Desktop/CMR/'))
if ~strcmp(pwd, '/Users/rebeccawilder/Desktop/CMR/')
    cd ('/Users/rebeccawilder/Desktop/CMR/')
end 
datafile= dir('*.mat');
load(datafile(2).name);
nsubj= unique(data.subject);
LL= data.listLength;
nsubj= unique(data.subject);
std_mat= nan(size(data.recalls(data.subject==nsubj(1) & data.session==1,:)));


for subj = 1:length(nsubj)
    for ses= 1:length(unique(data.session))
        
        ifr_idx= data.subject==nsubj(subj) & data.session== ses;
        if ~isempty(data.recalls(ifr_idx,:))
           
            %Set up serial position col:
            %correct numel and correct num of NaNs
            ifr_sp= data.recalls(ifr_idx,:);
            rec_mask= ifr_sp>0; %mask for intrusions and misses
            ifr_sp(~rec_mask)=nan;
            ifr_sp= reshape(ifr_sp', numel(ifr_sp),1);
            ifr_sp= ifr_sp(~isnan(ifr_sp));
            
            %Set up output position col:
            %correct numel and correct num of NaNs 
            ifr_op= std_mat;
            for i = 1:length(ifr_op(1,:))
                
                ifr_op(:,i)= i;
            end
            ifr_op(~rec_mask)=nan;
            ifr_op= reshape(ifr_op', numel(ifr_op),1);
            ifr_op= ifr_op(~isnan(ifr_op));
            
            %Set up response times col: 
            %correct numel and correct num of NaNs 
            ifr_rt= data.times(ifr_idx,:);
            ifr_rt(~rec_mask)=nan;
            ifr_rt= reshape(ifr_rt', numel(ifr_rt),1);
            ifr_rt= ifr_rt(~isnan(ifr_rt));
            
            %Set up subjects ID col: 
            ifr_subj= zeros(size(ifr_sp));
            ifr_subj(:,:)= nsubj(subj);
            
            %Set up session ID col: 
            ifr_ses= zeros(size(ifr_sp));
            ifr_ses(:,:)= ses;
            
            %Set up list ID col:
            %correct numel and correct num of NaNs
            ifr_list= std_mat;
            for i = 1:length(ifr_list(:,1))
                ifr_list(i,:)= i;
            end
            ifr_list(~rec_mask)= nan;
            ifr_list= reshape(ifr_list', numel(ifr_list),1);
            ifr_list= ifr_list(~isnan(ifr_list));
            
            
            %Set up rec itemnos ID col:
            %correct numel and correct num of NaNs
            ifr_itemnos= data.rec_itemnos(ifr_idx,:);
            ifr_itemnos(~rec_mask)=nan;
            ifr_itemnos= reshape(ifr_itemnos', numel(ifr_itemnos),1);
            ifr_itemnos= ifr_itemnos(~isnan(ifr_itemnos));
            
                
            all_data{subj, ses}= [ifr_subj, ifr_ses, ifr_list, ifr_sp, ifr_op, ifr_rt, ifr_itemnos];
            
            %each subj-ses combination should have 141 indices to start,
            %however, with nans 
            
            
            
            
            
            
        end 
    end 
    
        
end 
    
all_data= all_data(~cellfun('isempty', all_data));
all_data= cell2mat(all_data);
%% Saving Output
%name file something similar to output function
%if statement for if file exists warning about over-writing if it does
%already exist
user_input= input('To save output type ''save''\n', 's');
if strcmp(user_input, 'save')
    savefile= input('Please title your save file, excluding suffix, e.g. ''.csv'', ''.mat''  \n' ,'s');
    savefile= [savefile, '.csv'];
    dlmwrite(savefile, all_data)
end




