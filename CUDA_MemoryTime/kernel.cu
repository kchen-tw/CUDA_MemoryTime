#include <iostream>
#include <cuda_runtime.h>

int main(int argc, char* argv[]) {
    int N;

    // 檢查是否有提供命令列參數
    if (argc > 1) {
        // 將第一個命令列參數轉換為整數
        N = std::atoi(argv[1]);
    }
    else {
        // 如果沒有提供命令列參數，設定 N 為預設值 10
        N = 20;
    }

    // 定義陣列大小
    const int arraySize = 1 << N;
    std::cout << "Array Size = 2^" << N << std::endl;
    // 在主機上分配和初始化陣列
    int* h_data = new int[arraySize];
    for (int i = 0; i < arraySize; ++i) {
        h_data[i] = i + 1;
    }

    // 在裝置上分配陣列
    int* d_data;
    cudaMalloc(&d_data, sizeof(int) * arraySize);

    // 定義CUDA事件
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // 記錄開始時間
    cudaEventRecord(start);

    // 將資料從主機複製到裝置
    cudaMemcpy(d_data, h_data, sizeof(int) * arraySize, cudaMemcpyHostToDevice);

    // 記錄結束時間
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    // 計算執行時間
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    std::cout << "cudaMemcpy HostToDevice 執行時間: " << milliseconds << " 毫秒" << std::endl;

    // 記錄開始時間
    cudaEventRecord(start);

    // 將資料從裝置複製回主機
    cudaMemcpy(h_data, d_data, sizeof(int) * arraySize, cudaMemcpyDeviceToHost);

    // 記錄結束時間
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    // 計算執行時間
    milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    std::cout << "cudaMemcpy DeviceToHost 執行時間: " << milliseconds << " 毫秒" << std::endl;

    // 釋放記憶體
    delete[] h_data;
    cudaFree(d_data);

    // 銷毀CUDA事件
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
