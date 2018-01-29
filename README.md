# KinarmAnalysis

This repo host a collection of script for the analysis of kinarm data in Matlab enviroment developed during my master thesis project at KU Leuven in 2017. 
The scripts are organized as a series of nested classes. The idea is to automatize and standardize the analysis of those kind of data, as well as to organize the information in a more sensible structure.
They are intended to be used on reaching data.

# Usage
## Getting Started
Rename all the folders by putting a @ in front of them (__Experiment__ becomes __@Experiment__).
Afterwards don't forget to add them to the matlab path.

## Class hierarchy and properties description

              
#### Experiment fields
        Subjects        An array of subject objects
        Tasks           An array of task objects
        Parameters      A structure with a whole bunch of descriptive parameters
        Filename        A string containing the path where to store the data
              
#### Task fields
        Fs                      Samplig frequency
        NTrials                 Number of trials
        TaskProtocol            Name of the task protocol
        ID                      Int. Unique Task ID
        MovType                 Movement Type, can be CenterOut, OutCenter or Both
        UniqueMovements         A matrix containing for each unique movement the starting target and the ending target
        EventsDefinitions       A cell array containing the strings with the events names
        
                        All the *Tables are structures with a "Names" and a "Matrix" field. Names contains the column names. This will be updated by using the tables data type from Matlab.
        TargetTable
        LoadTable
        TrialProtocolTable
        BlockTable
        
        ChangeBlockIndex        [1xNBlocks] In this array is stored the trial index where a block change happens.
        CatchIndex              [1xNtrials] logical array stating true when a trial is a catch trial.
 
 #### Subjects Fields
        ID              Int. Unique ID for the subject
        Height          --|
        Weight          --|
        Age             --|
        DateOfBirth     --|
        Gender          --|     Infos taken directly from the c3d data.
        DominantHand    --|
        Notes           --|
        Classification  --|
        
        Sessions                Array of session class
        LinkedExperiment        Handle to the Experiment where this subject is contained. 
        
#### Session fields
        IntrestingData          Structure containing trial by trial organized data.
                EVENTS            Among others fields, the events are also stored here. EVENTS is a structure with the fields LABLES, the name if the occuring event, and TIMES, the time in seconds after the start of the trial when the event is occuring.
        c3d                     To be removed, here for debug.
        LinkedTask              Handle to related Task
        LinkedSubject           Handle to the Subject performing the task
        PausesIndex             If pauses are granted, the trial index immediatly after them goes here
        Hand                    Left or Right
        LateralDeviation        A measure of error trial by trial


## Methods description
