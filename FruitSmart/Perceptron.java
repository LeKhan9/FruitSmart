/*
 * Mohammad O. Khan
 * 9/5/2015
 * 
 * Perceptron capable of taking input, processing through sigmoid 
 * activation functions, forward propagating and backward propagating error
 * 
 * Works with NeuralNetwork class to train datasets -- Multi Layered Perceptron
 */
public class Perceptron {
	
	double inputs[]; 
	double weights[];
	int insertPoint = 1; // tracks position of next input into Perceptron
	double desiredOut;
	double deltaHid; // tracks delta value for delta sum -- see methods below
	
	public Perceptron(int inpSize){
		inputs = new double[inpSize+1];
		weights = new double[inpSize+1];
		inputs[0] = -1.0; 
	}
	
	public void input(double data){
		inputs[insertPoint++] = data;
		if(insertPoint == inputs.length){
			insertPoint = 1;
		}
	}
	
	// randomly assigns weights to each input
	public void setWeights(){
		for(int x = 0; x<weights.length; x++){
			weights[x] = -.5 + (Math.random()*1);
		}
	}
	
	// sums the product of the weights and inputs and
	// squashes the input with the sigmoid activation function
	public double actualOut(){
		
		double sum = 0.0;
		for(int x = 0; x<weights.length; x++){
			sum += inputs[x]*weights[x];
		}
		
		double sigmoid = 1 / (1 + Math.exp(-sum));
		return sigmoid;
	}
	
	// assigns a desired output for the Perceptron
	public void setDesiredOut(double x){
		desiredOut = x;
	}
	
	public double desiredOut(){
		return desiredOut;
	}
	
	public double error(){
		return desiredOut() - actualOut();
	}
	
	public double delta(){
		return actualOut() * (1-actualOut())* error(); 
	}
	
	// delta sum for hidden layer 2
	public double[] deltaSum2(){
		 double[] deltaSum = new double[weights.length];
		 for(int x = 0; x<weights.length; x++){
				deltaSum[x] = weights[x]*delta();
			}
		 return deltaSum;
	}
	
	// to track delta value from hidden layer 2 -- used along with 
	// method deltaSum1 below to obtain a sum of the deltas in the next layer
	public double deltaHid(double x){
		deltaHid = x;
		return deltaHid;
	}
	
	// delta sum for hidden layer 1 -- used in updating hidden layer 1
	// see method updateWeights3 below
	public double[] deltaSum1(){
		 double[] deltaSum = new double[weights.length];
		 for(int x = 0; x<weights.length; x++){
				deltaSum[x] = weights[x]*deltaHid;
			}
		 return deltaSum;
	}
	
	// for single Perceptron learning only
	public void updateWeights0(){
		
		double learningRate = .3;
		for(int x = 0; x<weights.length; x++){
			weights[x]= weights[x]+ (learningRate*inputs[x]*error());
		}
	}
	
	// for output node updating
	public void updateWeights1(){
		
		double learningRate = .3;
		for(int x = 0; x<weights.length; x++){
			weights[x]= weights[x]+ (learningRate*inputs[x]*delta());
		}
	}
	
	// for hidden layer 2 updating
	public void updateWeights2(double deltaSumOut){
		
		double learningRate = .3;
		for(int x = 0; x<weights.length; x++){
			weights[x]= weights[x]+ (learningRate*inputs[x]*deltaSumOut)* (actualOut()-1)*actualOut();
		}
	}
	
	// for hidden layer 1 update
	public void updateWeights3(){
		
		double learningRate = .3;
		for(int x = 0; x<weights.length; x++){
			weights[x]= weights[x]+ (learningRate*inputs[x]*deltaSum1()[x])* (actualOut()-1)*actualOut();
		}
	}
		
	// methods below for convenient access to weights and inputs
	 
	public double[] getInputs(){
		return inputs;
	}
	
	public double[] getWeights(){
		return weights; 
	}
	
	public void printWeights(){
		for(int x = 0; x<weights.length; x++){
			System.out.println("Weight" + x + ":  " + weights[x]);
		}
		System.out.println();
	}
	
	public void printInputs(){
		for(int x = 0; x<inputs.length; x++){
			System.out.print("["+ inputs[x]+"] " );
		}
		System.out.println();
	}
}
