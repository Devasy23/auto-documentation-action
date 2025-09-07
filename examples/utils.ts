export function calculateSum(numbers: number[]): number {
    return numbers.reduce((sum, num) => sum + num, 0);
}

export class DataProcessor {
    process(data: any[]): any[] {
        return data.filter(item => item !== null);
    }
}

export interface Config {
    apiUrl: string;
    timeout: number;
}
