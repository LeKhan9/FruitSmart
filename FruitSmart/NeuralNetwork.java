import java.io.*;
import java.util.*;

/*
 * Mohammad O. Khan
 * 9/5/2015
 * 
 * Dynamic Neural Network that takes in a input file dataset
 * and allows the user to determine hyper parameters listed below
 * - works with Perceptron class to use backpropagation for learning
 *   off of the dataset
 */
public class NeuralNetwork {

	public static void main(String[] args) throws FileNotFoundException, IOException{
		
		 /* ---------------------------------------------------
	     * 	This section takes a text file dataset 
	     * 	and reads it into a 2D array for NN input
	     * 
	     *  DYNAMIC HYPER-PARAMETERS (THROUGH USER INPUT):
	     *              1) # of inputs
	     * 				2) # of outputs
	     * 				3) # of nodes in first hidden layer
	     * 				4) # of nodes in second hidden layer
	     *              5) # of nodes in the output layer
	     *              6) (implicit) changing of learning rate
	     *              	in Perceptron class
	     *              7) # of cycles/epochs to run training for
	     *              
	     *  --> To test, first change the filename below with
	     *      the correct file path
	     -----------------------------------------------------*/
		String filename = ""; 
		 
	    Scanner read = new Scanner(System.in);
	    
	    System.out.println("Which method?");
	    System.out.println("1. H  ");
	    System.out.println("2. RGB ");
	    System.out.println("3. HSV ");
	    System.out.println("4. T ");
	    System.out.println("5. H and T ");



	    int chosenMethod = -1;
	    int option = read.nextInt();
        while(option != 1 && option != 2 && option !=3 && option!=4 && option!=5)
        {
       		System.out.println("Hmmm, which method?");
       		option = read.nextInt();
        }
	    if(option == 1 ) {filename = "hSet.txt"; chosenMethod = 1;}
	    else if(option == 2){ filename = "rgbSet.txt"; chosenMethod = 2;}
	    else if(option == 3){filename = "hsvSet.txt"; chosenMethod = 3;}
	    else if (option == 4){filename = "tSet.txt"; chosenMethod = 4;}
	    else {filename = "thSet.txt"; chosenMethod = 5;}


	    System.out.println("How many test rows?");
	    int rows = read.nextInt();
	    
	    System.out.println("How many inputs?");
	    int numInputs = read.nextInt();
	    
	    System.out.println("How many outputs?");
	    int numOutputs = read.nextInt();
	    
	    System.out.println("How many cycles do you want to run? Enter Number X: ");
		int cycles = read.nextInt();
		
	    int[] structure = new int[2];

	    int countx = 0;
	    while(countx < 2){
		    System.out.println("How many nodes in hidden layer " + (countx+1) + " ?");
		    structure[countx++] = read.nextInt();   
	    }
	    read.close();
	    
	    // the 2d array consisting of the dataset
	    double[][] data = new double[rows][(numInputs+numOutputs)];

	    try
	    {
		    FileReader readConnectionToFile = new FileReader(filename);
		    BufferedReader reads = new BufferedReader(readConnectionToFile);
		    Scanner scan = new Scanner(reads);
	
	    // reads input from file into a 2D array and prints the dataset
	    try
	    {
	        while(scan.hasNext())
	        {
	            for(int i = 0; i < rows; i++)
	            {
	 		        System.out.print("Set " + (i + 1) + " is: " );
	                for(int j = 0; j < data[i].length; j++)
	                {
	                  data[i][j] = scan.nextDouble();
	  		          System.out.print(data[i][j] + " ");
	                }
	 		        System.out.println();
	            }
	        }
	    } catch(InputMismatchException e)
	    {
	        System.out.println("Error converting number");
	    }
	    scan.close();
	    reads.close();
	    } catch (FileNotFoundException e)
	    {
	        System.out.println("File not found" + filename);
	    } catch (IOException e)
	    {
	        System.out.println("IO-Error open/close of file" + filename);
	    }
	    
	    /* ------------------------------------------------
	     * 			Start of Neural Network Training
	     * 		(after hyper-parameters are determined)
	     -------------------------------------------------*/
	    
	    // creates the outputs nodes and sets random weights
	    Perceptron[] outPer= new Perceptron[numOutputs];
		for(int i=0; i<numOutputs;i++)
		{
			outPer[i] = new Perceptron(structure[1]);
			outPer[i].setWeights();
		}
		
		// creates the first layer hidden nodes and sets random weights
		Perceptron[] hidLayer1= new Perceptron[structure[0]];
		for(int i=0; i<structure[0];i++)
		{
			hidLayer1[i] = new Perceptron(numInputs);
			hidLayer1[i].setWeights();
		}
		
		// creates the second layer hidden nodes and sets random weights
		Perceptron[] hidLayer2= new Perceptron[structure[1]];
		for(int i=0; i<structure[1];i++)
		{
			hidLayer2[i] = new Perceptron(structure[0]);
			hidLayer2[i].setWeights();
		}
		
		int epoch = 0;
		int row = 0;
		
		// this is the start of the actual training iterations
		while((epoch < cycles) && (row < rows)){
			
			System.out.println();
			if(row%rows==0){
				System.out.println(" Epoch # " + (epoch+1));
			}
			
			
			// inputs the dataset inputs into the first hidden layer
			int node = 0;
		    int inputx = 0;
		    
			while((node < structure[0]) && (inputx < numInputs))
			{
				hidLayer1[node].input(data[row][inputx++]);
				if(inputx==numInputs){
					inputx = 0;
					node++;
				}
			}
			
			// inputs the outputs of the first hidden layer into the second hidden layer
			node = 0;
			inputx = 0; 
			while((node < structure[1]) && (inputx < structure[0]))
			{
				hidLayer2[node].input(hidLayer1[inputx++].actualOut());
				if(inputx==structure[0]){
					inputx = 0;
					node++;
				}
			}


			
			// assigns desired outputs to any output nodes
			int outNode = 0;
			for(int i=numInputs;i<data[0].length;i++)
			{
				outPer[outNode++].setDesiredOut(data[row][i]);
			}
			
			// inputs the outputs of the second hidden layer into the output layer
			node = 0;
			inputx = 0; 
			while((node < numOutputs) && (inputx < structure[1]))
			{
				outPer[node].input(hidLayer2[inputx++].actualOut());
				if(inputx==structure[1]){
					inputx = 0;
					node++;
				}
			}

			
			// obtains the sum of the deltas for the second hidden layer to be used in backpropagation
			double[] deltaHidLayer2 = new double[structure[1]];
			
			for(int i=0; i<numOutputs;i++)
			{
				for(int j=0; j<structure[1]; j++){
					deltaHidLayer2[j]+= outPer[i].deltaSum2()[j];
				}
			}
			
			// obtains the sum of the deltas for the first hidden layer to be used in backpropagation
			double[] deltaHidLayer1 = new double[structure[0]];

			for(int i=0; i<structure[1]; i++){
				hidLayer2[i].deltaHid(deltaHidLayer2[i]);
			}
			
			for(int i=0; i<structure[1];i++)
			{
				for(int j=0; j<structure[0]; j++){
					deltaHidLayer1[j]+= hidLayer2[i].deltaSum1()[j];
				}
			}
			
			// updates the weights of the output layer
			for(int i=0; i<numOutputs;i++)
			{
				outPer[i].updateWeights1();
			}
			
			// updates the weights of the second hidden layer
			for(int i=0; i<structure[1]; i++){
				hidLayer2[i].updateWeights2(deltaHidLayer2[i]);
			}
			
			// updates the weights of the first hidden layer
			for(int i=0; i<structure[0]; i++){
				hidLayer1[i].updateWeights3();
			}
		
			// outputs the error for each set of the dataset rows
			for(int i=0; i<numOutputs;i++)
			{
				System.out.println("--- Error ---- : " + outPer[i].error());
			}
			
			row++;
			
			// once we complete a dataset, we reset the dataset and increment our epoch
			if(row == rows){
				row = 0;
				epoch++;
			}
		}
		
		try
		{

		    String filePort = "file.txt";
		    // if(chosenMethod == 1){
		    // 	filePort = "hWeights.txt";
		    // }
		    // if(chosenMethod == 2){
		    // 	filePort = "rgbWeights.txt";
		    // }
		    // if(chosenMethod == 3){
		    // 	filePort = "hsvWeights.txt";
		    // }


		    PrintWriter pr = new PrintWriter(filePort); 

		    int inputsTotal = numInputs +1;
		    pr.println((inputsTotal));
		    pr.println(structure[0]);
		    pr.println(structure[1]);

			for(int i=0; i<structure[0];i++)
			{
				for(int j=0; j<numInputs+1; j++){
					pr.println(hidLayer1[i].getWeights()[j]);
				}
			}
			for(int i=0; i<structure[1];i++)
			{
				for(int j=0; j<structure[0]+1; j++){
					pr.println(hidLayer2[i].getWeights()[j]);
				}
			}
			for(int i=0; i<numOutputs;i++)
			{
				for(int j=0; j<structure[1]+1; j++){
					pr.println(outPer[i].getWeights()[j]);
				}
			}
		 
		    pr.close();
		}
		catch (Exception e)
		{
		    e.printStackTrace();
		    System.out.println("No such file exists.");
		}

	}
}
