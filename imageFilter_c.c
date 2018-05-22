#include<stdio.h>
#include<stdlib.h>
void main()
{
    int h,i,j,k,l,sum,iterations;
    unsigned char datain[251][256]; /*Raw file data type implemented in two dimensional arrays*/
    unsigned char dataout[251][256];
    FILE* f;   /* Two FILE pointers to point at image stream */
    FILE* g;
    f=fopen("roller1.raw","rb");/* open raw file in read mode*/
    g=fopen("roller2.raw","wb");/*open raw file in write mode*/
    if(f==NULL)
    {
        printf("Error with roller1");
        EXIT_FAILURE;
    }
    if(g==NULL)
    {
        printf("Error with roller2");
        EXIT_FAILURE;
    }

    fread(datain,(250*255),1,f);  /*Read raw file(existing raw photo).use 2D-array pointer(pointer to pointer) to read image bytes */
    printf("Enter number of iterations :");
    scanf("%d",&iterations);
    printf("Computing results \n");
    for(i=0; i<=250; i++) /*Copy the data from the input array to the output array(Nested "for" because it is two dimensional array ) */
    {
        for(j=0; j<=255; j++)
        {
            *(*(dataout+i)+j) = *(*(datain+i)+j);
        }
    }
    for(h=1; h<=iterations; h++) /* Outside loop to repeat blurring operation  number of times specified by the user*/
    {
        for(i=1; i<=249; i++) /* For each row except the first and the last, compute a new value for each element*/
        {
            for(j=1; j<=254; j++) /*For each column except the first and the last, compute a new value for each element*/
            {
                sum=0;  /*For each element in the array, compute a new blurred value as described in the algorithm ....*/
                for(k=-1; k<=1; k++)
                {
                    for(l=-1; l<=1; l++)
                    {
                        sum = sum+(*(*(datain+(i+k))+(j+l)));
                    }
                    *(*(dataout+i)+j) = (sum+ (*(*(datain+i)+j))*7)/16; /*Sum currently contains the sum of the nine cells,
                                                    add in seven times the current cell so  we get a total of eight times the current cell.*/
                }
            }
        }
        for(i=0; i<=250; i++) /*Copy the output cell values back to the input cells so we can perform the blurring on this new data on
                               the next iteration. */
        {
            for(j=0; j<=255; j++)
            {
                *(*(datain+i)+j) = *(*(dataout+i)+j);
            }
        }
    }


    printf("Writting results \n ");
    fwrite(dataout,(250*255),1,g); /*Use 2D_array pointer(pointer to pointer) to write data in the new raw file(blured image) */
    fclose(f); /*close files */
    fclose(g);
}
