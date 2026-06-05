#ifndef ANSWER_H
#define ANSWER_H

int answer(void);

typedef enum answer_status {
    ANSWER_STATUS_OK = 0,
    ANSWER_STATUS_RETRY = 1,
    ANSWER_STATUS_FAILED = -1,
} answer_status;

answer_status answer_status_value(void);

#endif
