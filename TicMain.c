#include <stdio.h>
#include <stdlib.h>
/* Function Prototypes */
void setCol(int value);
void setRow(int value);
void printBoard();
void mainA();
void setX();
void initializeBoard();
void setO();
//bool checkWin();
int checkWin(int value);

int main()
{
        int row, col, row2, col2, exitSymbol;
	system("clear");
	initializeBoard();
        do {
		system("clear");
                printf("\n   Exit - 69 \n");

		printf("\n\n------------");
                printf("\nFIRST PLAYER\n");
		printf("------------\n");
		printf("\nEnter column: ");
		scanf("%d", &col);
		setCol(col);
		printf("Enter row: ");
		scanf("%d", &row);
		setRow(row);
		setX();
		printf("\n");
		printBoard();
		if(checkWin(1) == 1){
			printf("\n Xs Won!!!!");

			printf("Press 1 to exit ");
			scanf("%d", exitSymbol);
			if(exitSymbol == 1){
				exit(0);
			}
		}

		if(row == 69 | col == 69){
			exit(0);
		}


		printf("\n\n-------------\n");
		printf("SECOND PLAYER\n");
		printf("-------------\n\n");
		printf("Enter column: ");
		scanf("%d", &col2);
		setCol(col2);
		printf("Enter row: ");
		scanf("%d", &row2);
		setRow(row2);
		setO();
		printBoard();
		if(checkWin(2)== 1){
			printf("\n Os Won!!!!");

			printf("Press 1 to exit ");
			scanf("%d", exitSymbol);
			if(exitSymbol == 1){
				exit(0);
			}
		}

            // scanf("%d", &operation);
/*
                switch (operation) {
                        case 1:
                                printf("\nEnter the positive integer value to be pushed: ");
                                scanf("%d", &value);
                                push(value);
                                break;
                        case 2:
                                value = pop();
                                if (value != -1)
                                        printf("\nPopped value is %d\n", value);
                                break;
                        case 3:
                                display();
                                break;
                        case 4:
                                printf("\nTerminating program\n");
                                exit(0);
                        default:
                                printf("\nInvalid option! Try again.\n");
                                break;
                }
                printf("\nPress the return key to continue . . . ");

                getchar();
                getchar();

*/
		if(row == 69 | col == 69){
			exit(0);
		}

		printf("\nPress the return key to continue . . . ");

                getchar();
                getchar();


        } while (row != 69 && col !=69);
        return 0;
}
