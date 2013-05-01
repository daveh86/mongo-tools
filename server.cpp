#include <iostream>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>

#define PORT "3490"  // the port users will be connecting to

#define BACKLOG 10	 // how many pending connections queue will hold
#define MAXDATASIZE 100 // max number of bytes we can get at once 

using namespace std;

void sigchld_handler(int s)
{
	while(waitpid(-1, NULL, WNOHANG) > 0);
}

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
	if (sa->sa_family == AF_INET) {
		return &(((struct sockaddr_in*)sa)->sin_addr);
	}

	return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int main(int argc, char *argv[])
{
	if(argc != 2){
		cerr << "usage: server port" << endl;
		exit(1);
	}
	int numbytes, sockfd, new_fd;  // listen on sock_fd, new connection on new_fd
	struct addrinfo hints, *servinfo, *p;
	struct sockaddr_storage their_addr; // connector's address information
	socklen_t sin_size;
	struct sigaction sa;
	int yes=1;
	char s[INET6_ADDRSTRLEN];
	int rv;
	char buf[MAXDATASIZE];

	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_INET; //IPv4 rather than AF_UNSPEC
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_PASSIVE; // use my IP

	if ((rv = getaddrinfo(NULL, argv[1], &hints, &servinfo)) != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
		return 1;
	}

	// loop through all the results and bind to the first we can
	for(p = servinfo; p != NULL; p = p->ai_next) {
		if ((sockfd = socket(p->ai_family, p->ai_socktype,
				p->ai_protocol)) == -1) {
			perror("server: socket");
			continue;
		}

		if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
				sizeof(int)) == -1) {
			perror("setsockopt");
			exit(1);
		}

		if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
			close(sockfd);
			perror("server: bind");
			continue;
		}

		break;
	}

	if (p == NULL)  {
		fprintf(stderr, "server: failed to bind\n");
		return 2;
	}

	freeaddrinfo(servinfo); // all done with this structure

	if (listen(sockfd, BACKLOG) == -1) {
		perror("listen");
		exit(1);
	}

	sa.sa_handler = sigchld_handler; // reap all dead processes
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_RESTART;
	if (sigaction(SIGCHLD, &sa, NULL) == -1) {
		perror("sigaction");
		exit(1);
	}

	printf("server: waiting for connections...\n");
	signal(SIGPIPE, SIG_IGN);
	sin_size = sizeof their_addr;
	new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);
	if (new_fd == -1) {
		perror("accept");
	}

	inet_ntop(their_addr.ss_family,
		get_in_addr((struct sockaddr *)&their_addr),
		s, sizeof s);
	cout << "server: got connection from " << s << endl;

	int counter = 0;
	int sval = 2;
	int ret;
	double diff;
	time_t start,end;
	while(true){
		counter++;
		ret = send(new_fd, "Hello, world!", 13, 0);
		if(ret == -1){
			cerr << "---FAIL---" << endl;
			perror("send");
			close(new_fd);
			exit(1);
		}
		time(&start);
		numbytes = recv(new_fd, buf, MAXDATASIZE-1, 0);
                if (numbytes == -1) {
                        cerr << "---FAIL---" << endl;
                        perror("send");
                        close(new_fd);
                        exit(1);
                }
		time(&end);
		diff = difftime (end,start);
                buf[numbytes] = '\0';
		printf("server: received '%s' over '%.2f' seconds\n",buf, diff);
		sleep(pow(sval,counter));
	}

	return 0;
}

