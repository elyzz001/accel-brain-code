# -*- coding: utf-8 -*-
from logging import getLogger
import numpy as np
cimport numpy as np
from pydbm.rnn.verification.interface.verificatable_result import VerificatableResult
from pydbm.rnn.loss.interface.computable_loss import ComputableLoss
import pandas as pd


class VerificateFunctionApproximation(VerificatableResult):
    '''
    Verification of softmax result.
    '''

    # Logs of accuracy.
    __logs_tuple_list = []
    
    # Logger.
    __logger = None
    
    def __init__(self, computable_loss):
        '''
        Init.
        
        Args:
            computable_loss:    is-a `OptimizableLoss`.

        '''

        if isinstance(computable_loss, ComputableLoss):
            self.__computable_loss = computable_loss
        else:
            raise TypeError()

        logger = getLogger("pydbm")
        self.__logger = logger

    def verificate(
        self,
        np.ndarray train_pred_arr,
        np.ndarray train_label_arr,
        np.ndarray test_pred_arr,
        np.ndarray test_label_arr
    ):
        '''
        Verificate result.

        Args:
            train_pred_arr:    Predicted data in training.
            train_label_arr:   Labeled data in training.
            test_pred_arr:     Predicted data in test.
            test_label_arr:    Labeled data in test.

        '''
        train_loss = self.__computable_loss.compute_loss(train_pred_arr, train_label_arr)
        test_loss = self.__computable_loss.compute_loss(test_pred_arr, test_label_arr)

        self.__logger.debug("Epoch: " + str(len(self.__logs_tuple_list) + 1))

        self.__logger.debug("Loss: ")
        self.__logger.debug(
            "Training: " + str(train_loss) + " Test: " + str(test_loss)
        )

        if len(self.__logs_tuple_list) > 9:
            df = pd.DataFrame(
                self.__logs_tuple_list[-10:],
                columns=[
                    "train_loss",
                    "test_loss"
                ]
            )
            self.__logger.debug("Rolling mean of Loss (Window is 10): ")
            self.__logger.debug(
                "Training: " + str(df.train_loss.mean()) + " Test: " + str(df.test_loss.mean())
            )
        
        self.__logs_tuple_list.append(
            (
                train_loss,
                test_loss
            )
        )

    def get_logs_df(self):
        ''' getter '''
        return pd.DataFrame(
            self.__logs_tuple_list,
            columns=[
                "train_loss",
                "test_loss"
            ]
        )

    def set_readonly(self, value):
        ''' setter '''
        raise TypeError()
    
    logs_df = property(get_logs_df, set_readonly)
