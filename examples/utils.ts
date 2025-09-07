/**
 * Calculates the sum of an array of numbers.
 * @param numbers - An array of numbers to sum.
 * @returns The sum of the numbers in the array.
 */
export function calculateSum(numbers: number[]): number {
    return numbers.reduce((sum, num) => sum + num, 0);
}

/**
 * A class for processing data.
 */
export class DataProcessor {
    /**
     * Processes an array of data, removing null values.
     * @param data - The array of data to process.
     * @returns A new array with null values removed.
     */
    process(data: any[]): any[] {
        return data.filter(item => item !== null);
    }
}

/**
 * Configuration interface.
 */
export interface Config {
    /** API url */
    apiUrl: string;
    /** Timeout in milliseconds */
    timeout: number;
}
